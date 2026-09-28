import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/user_avatar.dart';

/// Bolha de mensagem de áudio: avatar de quem enviou, botão de play,
/// waveform e tempo.
///
/// Arquitetura (importante pra não voltar os bugs antigos):
/// - A REPRODUÇÃO é feita pelo `video_player` (que já é usado nos vídeos
///   do chat). Ele dá duração e posição confiáveis, permite tocar de novo
///   depois do fim e não tem os crashes de dispose do player do
///   audio_waveforms.
/// - O `audio_waveforms` é usado SÓ pra extrair as amplitudes da onda
///   ([PlayerController.waveformExtraction]); o controller dele é
///   descartado logo depois da extração, sem nunca tocar nada.
/// - A onda é desenhada aqui mesmo ([_WaveformPainter]) e o progresso dela
///   e o contador de tempo saem da MESMA posição ([_posicao]) — por isso
///   os dois andam juntos.
class AudioMensagem extends StatefulWidget {
  final String? url;
  final String? avatarUrl;
  final bool minha;

  const AudioMensagem({
    required this.url,
    required this.avatarUrl,
    required this.minha,
    super.key,
  });

  @override
  State<AudioMensagem> createState() => _AudioMensagemState();
}

class _AudioMensagemState extends State<AudioMensagem>
    with SingleTickerProviderStateMixin {
  static const _margemFim = Duration(milliseconds: 80);

  VideoPlayerController? _video;
  Future<void>? _inicializacao;

  /// Só serve de "relógio" pra redesenhar a onda/tempo enquanto toca — o
  /// video_player só avisa a posição a cada ~500 ms, o que ficaria
  /// travado. Entre um aviso e outro, a posição é interpolada.
  late final AnimationController _ticker = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  bool _disposed = false;

  bool _preparado = false;
  bool _falhaAoCarregar = false;
  bool _tocando = false;
  bool _fimTratado = false;

  List<double> _amplitudes = const [];
  Duration _total = Duration.zero;

  // Última posição informada pelo player e o instante em que chegou.
  Duration _posBase = Duration.zero;
  DateTime _posEm = DateTime.now();

  @override
  void initState() {
    super.initState();
    _preparar();
  }

  // ------------------------------------------------------------- preparo

  Future<void> _preparar() async {
    final url = widget.url;
    if (url == null) {
      if (mounted) setState(() => _falhaAoCarregar = true);
      return;
    }

    try {
      final caminho = await _baixarArquivoTemporario(url);
      if (_disposed) return;

      final controller = VideoPlayerController.file(File(caminho));
      _video = controller;
      controller.addListener(_aoMudarVideo);

      final inicializacao = controller.initialize();
      _inicializacao = inicializacao;
      await inicializacao;
      if (_disposed) return; // o dispose() cuida de liberar o controller

      setState(() {
        _preparado = true;
        _total = controller.value.duration;
      });

      // A onda chega depois; até lá o áudio já pode ser tocado.
      unawaited(_extrairWaveform(caminho));
    } catch (_) {
      if (mounted && !_disposed) setState(() => _falhaAoCarregar = true);
    }
  }

  Future<String> _baixarArquivoTemporario(String url) async {
    final resposta = await http.get(Uri.parse(url));

    if (resposta.statusCode != 200) {
      throw Exception('Falha ao baixar áudio: HTTP ${resposta.statusCode}');
    }
    final diretorio = await getTemporaryDirectory();
    final caminho =
        '${diretorio.path}/audio_${DateTime.now().microsecondsSinceEpoch}.m4a';
    await File(caminho).writeAsBytes(resposta.bodyBytes);
    return caminho;
  }

  /// Extrai as amplitudes com um PlayerController descartável. O
  /// controller só é liberado DEPOIS de a extração terminar (evita o crash
  /// nativo "codec is released already") e nunca chega a tocar nada, então
  /// o dispose dele é seguro.
  Future<void> _extrairWaveform(String caminho) async {
    final extrator = PlayerController();
    try {
      final dados = await extrator.waveformExtraction.extractWaveformData(
        path: caminho,
        noOfSamples: 60,
      );
      if (_disposed || !mounted) return;
      setState(() => _amplitudes = dados);
    } catch (_) {
      // Sem onda: ficam barras neutras, o áudio toca normalmente.
    } finally {
      // O dispose() do PlayerController é `async void`: um erro nativo nele
      // (ex: release de um player que nunca foi preparado) escaparia como
      // exceção não tratada. Rodar dentro de runZonedGuarded captura isso.
      runZonedGuarded(extrator.dispose, (erro, pilha) {});
    }
  }

  // ------------------------------------------------------------ reprodução

  void _aoMudarVideo() {
    final video = _video;
    if (video == null || _disposed || !mounted) return;

    final valor = video.value;
    if (!valor.isInitialized) return;

    final total = valor.duration;
    final terminou =
        total > Duration.zero &&
        valor.position >= total - _margemFim &&
        !valor.isPlaying;

    if (terminou) {
      if (!_fimTratado) {
        _fimTratado = true;
        // Volta ao início: o próximo play toca do começo.
        _posBase = Duration.zero;
        _posEm = DateTime.now();
        video.seekTo(Duration.zero);
        _definirTocando(false);
      }
      return;
    }

    if (valor.isPlaying) _fimTratado = false;
    _posBase = valor.position;
    _posEm = DateTime.now();
    _definirTocando(valor.isPlaying);
  }

  void _definirTocando(bool tocando) {
    if (tocando == _tocando) return;
    setState(() => _tocando = tocando);
    if (tocando) {
      _ticker.repeat();
    } else {
      _ticker.stop();
    }
  }

  Future<void> _alternarReproducao() async {
    final video = _video;
    if (video == null || !_preparado || _disposed) return;

    try {
      if (video.value.isPlaying) {
        await video.pause();
        return;
      }
      if (_total > Duration.zero &&
          video.value.position >= _total - _margemFim) {
        await video.seekTo(Duration.zero);
      }
      await video.play();
    } catch (_) {
      if (mounted && !_disposed) setState(() => _falhaAoCarregar = true);
    }
  }

  void _buscar(double fracao) {
    final video = _video;
    if (video == null || !_preparado || _total == Duration.zero) return;

    final alvo = Duration(
      milliseconds: (_total.inMilliseconds * fracao.clamp(0.0, 1.0)).round(),
    );
    _fimTratado = false;
    _posBase = alvo;
    _posEm = DateTime.now();
    setState(() {});
    video.seekTo(alvo);
  }

  /// Posição atual, usada tanto pela onda quanto pelo contador.
  Duration _posicao() {
    if (!_tocando) return _posBase;
    final estimada = _posBase + DateTime.now().difference(_posEm);
    return estimada > _total ? _total : estimada;
  }

  // ------------------------------------------------------------------ UI

  String _formatarDuracao(Duration duracao) {
    final minutos = duracao.inMinutes.toString().padLeft(2, '0');
    final segundos = (duracao.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker.dispose();

    final video = _video;
    if (video != null) {
      video.removeListener(_aoMudarVideo);
      // Nunca descarta no meio do initialize() — mesmo cuidado do
      // VideoMensagem.
      final inicializacao = _inicializacao;
      if (inicializacao == null) {
        video.dispose();
      } else {
        inicializacao.whenComplete(video.dispose).catchError((_) {});
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minha = widget.minha;

    // Sobre o fundo vermelho (minha) o botão é branco; sobre o cinza
    // (recebida) o botão é vermelho.
    final corBotao = minha ? Colors.white : AppColors.primary;
    final corIconeBotao = minha ? AppColors.primary : Colors.white;
    final corTexto = minha ? Colors.white70 : AppColors.textoSecundario;

    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, _) {
        final posicao = _posicao();
        final progresso = _total > Duration.zero
            ? (posicao.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;
        final exibida = posicao > Duration.zero ? posicao : _total;

        return SizedBox(
          width: 250,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(avatarUrl: widget.avatarUrl, radius: 16),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _preparado ? _alternarReproducao : null,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _falhaAoCarregar ? Colors.transparent : corBotao,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: !_preparado
                        ? (_falhaAoCarregar
                              ? Icon(
                                  Icons.error_outline_rounded,
                                  size: 22,
                                  color: corTexto,
                                )
                              : SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: corIconeBotao,
                                  ),
                                ))
                        : Icon(
                            _tocando
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 24,
                            color: corIconeBotao,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Waveform(
                  amplitudes: _amplitudes,
                  progresso: progresso,
                  corTocada: minha ? Colors.white : AppColors.primary,
                  corRestante: minha
                      ? Colors.white54
                      : AppColors.primary.withValues(alpha: 0.3),
                  onBuscar: _preparado ? _buscar : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatarDuracao(exibida),
                style: TextStyle(fontSize: 11, color: corTexto),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Onda do áudio: barras arredondadas, coloridas até o ponto já tocado.
/// Tocar/arrastar sobre ela pula pra aquele ponto.
class _Waveform extends StatelessWidget {
  final List<double> amplitudes;
  final double progresso;
  final Color corTocada;
  final Color corRestante;
  final ValueChanged<double>? onBuscar;

  const _Waveform({
    required this.amplitudes,
    required this.progresso,
    required this.corTocada,
    required this.corRestante,
    required this.onBuscar,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;

        void buscar(double dx) {
          if (onBuscar == null || largura <= 0) return;
          onBuscar!(dx / largura);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => buscar(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => buscar(d.localPosition.dx),
          child: SizedBox(
            height: 32,
            width: double.infinity,
            child: CustomPaint(
              painter: _WaveformPainter(
                amplitudes: amplitudes,
                progresso: progresso,
                corTocada: corTocada,
                corRestante: corRestante,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final double progresso;
  final Color corTocada;
  final Color corRestante;

  _WaveformPainter({
    required this.amplitudes,
    required this.progresso,
    required this.corTocada,
    required this.corRestante,
  });

  static const _larguraBarra = 3.0;
  static const _espaco = 3.0;

  /// Reduz/estica as amplitudes pra exatamente [n] barras (pega o pico de
  /// cada trecho) e normaliza pra 0..1.
  List<double> _reamostrar(int n) {
    if (amplitudes.isEmpty) return List.filled(n, 0.25);

    final abs = amplitudes.map((a) => a.abs()).toList();
    final maior = abs.reduce(math.max);
    if (maior <= 0) return List.filled(n, 0.25);

    return List.generate(n, (i) {
      final ini = (i * abs.length / n).floor();
      final fim = math.min(
        abs.length,
        math.max(ini + 1, ((i + 1) * abs.length / n).floor()),
      );
      var pico = 0.0;
      for (var j = ini; j < fim; j++) {
        pico = math.max(pico, abs[j]);
      }
      return (pico / maior).clamp(0.12, 1.0).toDouble();
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = ((size.width + _espaco) / (_larguraBarra + _espaco))
        .floor()
        .clamp(1, 200);
    final barras = _reamostrar(n);
    final passo = size.width / n;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _larguraBarra;

    for (var i = 0; i < n; i++) {
      final x = passo * i + passo / 2;
      final altura = math.max(4.0, barras[i] * size.height);
      final topo = (size.height - altura) / 2;

      paint.color = (i + 0.5) / n <= progresso ? corTocada : corRestante;
      canvas.drawLine(Offset(x, topo), Offset(x, topo + altura), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) {
    return old.progresso != progresso ||
        old.amplitudes != amplitudes ||
        old.corTocada != corTocada ||
        old.corRestante != corRestante;
  }
}
