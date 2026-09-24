import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'widgets/anexo_selecionado.dart';

/// Resultado devolvido pela câmera quando o usuário toca em "Usar".
class CapturaResultado {
  final XFile arquivo;
  final TipoAnexo tipo;

  const CapturaResultado({required this.arquivo, required this.tipo});
}

/// Câmera estilo WhatsApp:
/// - toque no botão = foto
/// - segurar o botão = vídeo (solta pra parar)
/// - arrastar pra cima enquanto grava = zoom
/// - pinch na tela = zoom
class CameraCapturaScreen extends StatefulWidget {
  /// Se false (microfone negado), a câmera abre sem áudio.
  final bool gravarComAudio;

  const CameraCapturaScreen({this.gravarComAudio = true, super.key});

  @override
  State<CameraCapturaScreen> createState() => _CameraCapturaScreenState();
}

class _CameraCapturaScreenState extends State<CameraCapturaScreen>
    with WidgetsBindingObserver {
  static const _duracaoMaxima = Duration(minutes: 1);
  static const _zoomMaximoPermitido = 8.0;

  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _indiceCamera = 0;
  FlashMode _flash = FlashMode.off;

  bool _capturando = false;
  bool _iniciandoGravacao = false;
  bool _soltouAntesDeComecar = false;
  bool _gravando = false;
  Duration _tempoGravacao = Duration.zero;
  Timer? _timer;

  double _zoomMin = 1;
  double _zoomMax = 1;
  double _zoomAtual = 1;
  double _zoomBase = 1;

  DateTime? _inicioGravacao;

  String? _erro;

  bool get _lenteTraseira =>
      _cameras.isNotEmpty &&
      _cameras[_indiceCamera].lensDirection == CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _iniciar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _timer?.cancel();
      setState(() {
        _controller = null;
        _gravando = false;
      });
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _usarCamera(_indiceCamera);
    }
  }

  // ---------------------------------------------------------------- setup

  Future<void> _iniciar() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) setState(() => _erro = 'Nenhuma câmera encontrada.');
        return;
      }
      final traseira = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _indiceCamera = traseira >= 0 ? traseira : 0;
      await _usarCamera(_indiceCamera);
    } on CameraException {
      if (mounted) setState(() => _erro = 'Não foi possível abrir a câmera.');
    }
  }

  Future<void> _usarCamera(int indice) async {
    final antigo = _controller;
    if (antigo != null) {
      setState(() => _controller = null);
      await antigo.dispose();
    }

    final novo = CameraController(
      _cameras[indice],
      ResolutionPreset.high,
      enableAudio: widget.gravarComAudio,
    );

    try {
      await novo.initialize();
      await novo.lockCaptureOrientation(DeviceOrientation.portraitUp);
      _zoomMin = await novo.getMinZoomLevel();
      _zoomMax = math.min(await novo.getMaxZoomLevel(), _zoomMaximoPermitido);
      _zoomAtual = _zoomMin;
      try {
        await novo.setFlashMode(_lenteTraseira ? _flash : FlashMode.off);
      } catch (_) {
        // câmera frontal normalmente não tem flash
      }
    } on CameraException {
      await novo.dispose();
      if (mounted) setState(() => _erro = 'Não foi possível abrir a câmera.');
      return;
    }

    if (!mounted) {
      await novo.dispose();
      return;
    }
    setState(() {
      _controller = novo;
      _erro = null;
    });
  }

  // ---------------------------------------------------------- flash / lente

  Future<void> _alternarFlash() async {
    final controller = _controller;
    if (controller == null || !_lenteTraseira) return;

    final proximo = switch (_flash) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      _ => FlashMode.off,
    };
    try {
      await controller.setFlashMode(proximo);
      setState(() => _flash = proximo);
    } catch (_) {}
  }

  Future<void> _trocarCamera() async {
    if (_gravando || _capturando) return;
    final atual = _cameras[_indiceCamera].lensDirection;
    final destino = atual == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final indice = _cameras.indexWhere((c) => c.lensDirection == destino);
    if (indice < 0) return;
    _indiceCamera = indice;
    await _usarCamera(indice);
  }

  // ------------------------------------------------------------------- zoom

  Future<void> _aplicarZoom(double zoom) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final z = math.max(_zoomMin, math.min(_zoomMax, zoom));
    if (z == _zoomAtual) return;
    _zoomAtual = z;
    try {
      await controller.setZoomLevel(z);
    } catch (_) {}
  }

  void _aoArrastarGravando(LongPressMoveUpdateDetails detalhes) {
    if (!_gravando) return;
    // 300 px de arrasto pra cima = zoom máximo
    final t = (-detalhes.offsetFromOrigin.dy / 300).clamp(0.0, 1.0);
    _aplicarZoom(_zoomMin + (_zoomMax - _zoomMin) * t);
  }

  // ------------------------------------------------------------------ foto

  Future<void> _tirarFoto() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _capturando ||
        _gravando ||
        _iniciandoGravacao ||
        controller.value.isTakingPicture) {
      return;
    }
    _capturando = true;
    try {
      final foto = await controller.takePicture();
      if (!mounted) return;
      await _revisar(foto, TipoAnexo.imagem);
    } on CameraException {
      _mostrarErro('Não foi possível tirar a foto.');
    } finally {
      _capturando = false;
    }
  }

  // ----------------------------------------------------------------- vídeo

  Future<void> _iniciarGravacao() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _capturando ||
        _gravando ||
        _iniciandoGravacao) {
      return;
    }
    _iniciandoGravacao = true;
    _soltouAntesDeComecar = false;

    try {
      if (_flash != FlashMode.off && _lenteTraseira) {
        await controller.setFlashMode(FlashMode.torch);
      }
      await controller.prepareForVideoRecording();
      await controller.startVideoRecording();
      _inicioGravacao = DateTime.now();
      if (!mounted) return;

      HapticFeedback.mediumImpact();
      setState(() {
        _gravando = true;
        _tempoGravacao = Duration.zero;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _tempoGravacao += const Duration(seconds: 1));
        if (_tempoGravacao >= _duracaoMaxima) _finalizarGravacao();
      });
    } on CameraException {
      _mostrarErro('Não foi possível gravar o vídeo.');
    } finally {
      _iniciandoGravacao = false;
    }

    // o usuário soltou o dedo enquanto a gravação ainda estava começando
    if (_soltouAntesDeComecar && _gravando) await _finalizarGravacao();
  }

  void _aoSoltarBotao() {
    if (_iniciandoGravacao) {
      _soltouAntesDeComecar = true;
    } else {
      _finalizarGravacao();
    }
  }

  Future<void> _finalizarGravacao() async {
    if (!_gravando) return;

    // marca como finalizado logo de cara pra evitar chamada dupla
    _gravando = false;
    _timer?.cancel();
    if (mounted) setState(() {});

    final controller = _controller;
    if (controller == null) return;

    try {
      // parar cedo demais trava o plugin: garante um tempo mínimo gravado
      final inicio = _inicioGravacao;
      if (inicio != null) {
        const minimo = Duration(milliseconds: 1200);
        final decorrido = DateTime.now().difference(inicio);
        if (decorrido < minimo) await Future.delayed(minimo - decorrido);
      }

      if (!mounted || !controller.value.isRecordingVideo) return;

      final video = await controller.stopVideoRecording();
      await _aplicarZoom(_zoomMin);
      if (_lenteTraseira) {
        try {
          await controller.setFlashMode(_flash);
        } catch (_) {}
      }
      if (!mounted) return;
      await _revisar(video, TipoAnexo.video);
    } on CameraException catch (e) {
      debugPrint('Erro ao parar gravação: ${e.code} - ${e.description}');
      _mostrarErro('Não foi possível salvar o vídeo.');
    }
  }

  // ---------------------------------------------------------------- prévia

  Future<void> _revisar(XFile arquivo, TipoAnexo tipo) async {
    final usar = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PreviaCapturaScreen(arquivo: arquivo, tipo: tipo),
      ),
    );
    if (!mounted) return;

    if (usar == true) {
      Navigator.of(context).pop(CapturaResultado(arquivo: arquivo, tipo: tipo));
    } else {
      // "Refazer": descarta o arquivo temporário e volta pra câmera
      try {
        await File(arquivo.path).delete();
      } catch (_) {}
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // -------------------------------------------------------------------- UI

  String _formatarDuracao(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _construirPreview(CameraController controller) {
    // preenche a tela toda (estilo "cover"), cortando o excesso
    final tela = MediaQuery.of(context).size;
    var escala = tela.aspectRatio * controller.value.aspectRatio;
    if (escala < 1) escala = 1 / escala;
    return ClipRect(
      child: Transform.scale(
        scale: escala,
        child: Center(child: CameraPreview(controller)),
      ),
    );
  }

  IconData get _iconeFlash => switch (_flash) {
    FlashMode.auto => Icons.flash_auto,
    FlashMode.always || FlashMode.torch => Icons.flash_on,
    _ => Icons.flash_off,
  };

  Widget _construirBotaoCaptura() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // se já está gravando, tocar para; senão tira foto
      onTap: () => _gravando ? _finalizarGravacao() : _tirarFoto(),
      onLongPressStart: (_) => _iniciarGravacao(),
      onLongPressMoveUpdate: _aoArrastarGravando,
      onLongPressEnd: (_) => _aoSoltarBotao(),
      onLongPressCancel: _aoSoltarBotao,
      child: SizedBox(
        width: 96,
        height: 96,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: _gravando ? 96 : 76,
            height: _gravando ? 96 : 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: _gravando ? 36 : 60,
                height: _gravando ? 36 : 60,
                decoration: BoxDecoration(
                  color: _gravando ? Colors.redAccent : Colors.white,
                  shape: _gravando ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: _gravando ? BorderRadius.circular(8) : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final pronto = controller != null && controller.value.isInitialized;

    return PopScope(
      canPop: !_gravando,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (pronto)
              GestureDetector(
                onScaleStart: (_) => _zoomBase = _zoomAtual,
                onScaleUpdate: (d) {
                  if (d.pointerCount >= 2) _aplicarZoom(_zoomBase * d.scale);
                },
                child: _construirPreview(controller),
              )
            else
              Center(
                child: _erro != null
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _erro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    : const CircularProgressIndicator(color: Colors.white),
              ),
            SafeArea(
              child: Column(
                children: [
                  // barra superior
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _gravando
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                          tooltip: 'Fechar',
                        ),
                        Expanded(
                          child: Center(
                            child: _gravando
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.fiber_manual_record,
                                          color: Colors.redAccent,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatarDuracao(_tempoGravacao),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        if (_lenteTraseira && !_gravando)
                          IconButton(
                            onPressed: _alternarFlash,
                            icon: Icon(_iconeFlash, color: Colors.white),
                            tooltip: 'Flash',
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Opacity(
                      opacity: _gravando ? 0 : 1,
                      child: const Text(
                        'Toque para foto, segure para vídeo',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ),
                  // controles inferiores
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),
                        _construirBotaoCaptura(),
                        if (_gravando || _cameras.length < 2)
                          const SizedBox(width: 48)
                        else
                          IconButton(
                            onPressed: _trocarCamera,
                            icon: const Icon(
                              Icons.flip_camera_android_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            tooltip: 'Trocar câmera',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tela de prévia depois de capturar: "Refazer" (false) ou "Usar" (true).
class PreviaCapturaScreen extends StatefulWidget {
  final XFile arquivo;
  final TipoAnexo tipo;

  const PreviaCapturaScreen({
    required this.arquivo,
    required this.tipo,
    super.key,
  });

  @override
  State<PreviaCapturaScreen> createState() => _PreviaCapturaScreenState();
}

class _PreviaCapturaScreenState extends State<PreviaCapturaScreen> {
  VideoPlayerController? _video;

  @override
  void initState() {
    super.initState();
    if (widget.tipo == TipoAnexo.video) {
      final controller = VideoPlayerController.file(File(widget.arquivo.path));
      _video = controller;
      controller.initialize().then((_) {
        if (!mounted) return;
        controller
          ..setLooping(true)
          ..play();
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  Widget _conteudo() {
    if (widget.tipo == TipoAnexo.imagem) {
      return Image.file(File(widget.arquivo.path), fit: BoxFit.contain);
    }
    final video = _video;
    if (video == null || !video.value.isInitialized) {
      return const CircularProgressIndicator(color: Colors.white);
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          video.value.isPlaying ? video.pause() : video.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: video.value.aspectRatio,
            child: VideoPlayer(video),
          ),
          if (!video.value.isPlaying)
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xAA000000),
              child: Icon(Icons.play_arrow, color: Colors.white, size: 32),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Center(child: _conteudo())),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      'Refazer',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.check),
                    label: const Text('Usar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
