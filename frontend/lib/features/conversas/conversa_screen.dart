import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ajudai/core/routes/app_routes.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/shared.dart';
import 'package:video_player/video_player.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/session/sessao.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/user_avatar.dart';
import '../../core/ws/ws_message_stream.dart';
import 'conversas_repository.dart';

class ConversaScreen extends StatefulWidget {
  final ConversaResumo conversa;

  const ConversaScreen({required this.conversa, super.key});

  @override
  State<ConversaScreen> createState() => _ConversaScreenState();
}

class _ConversaScreenState extends State<ConversaScreen> {
  final _repository = ConversasRepository();
  final _imagePicker = ImagePicker();
  final _textoController = TextEditingController();
  final _scrollController = ScrollController();
  final _mensagens = <MensagemComUrl>[];
  StreamSubscription<MensagemComUrl>? _novasMensagensSubscription;

  bool _carregando = true;
  bool _enviando = false;
  String? _erro;
  _AnexoSelecionado? _anexoSelecionado;

  String? get _usuarioId => Sessao.instance.usuario?.id;

  @override
  void initState() {
    super.initState();
    _carregarMensagens();
    _novasMensagensSubscription = _repository.escutarNovasMensagens().listen(
      _adicionarMensagemRecebida,
    );
  }

  @override
  void dispose() {
    _novasMensagensSubscription?.cancel();
    _textoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _carregarMensagens() async {
    try {
      final mensagens = await _repository.listarMensagens(
        widget.conversa.conversaId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _mensagens
          ..clear()
          ..addAll(
            mensagens.where(
              (item) => item.mensagem.conversaId == widget.conversa.conversaId,
            ),
          );
        _mensagens.sort(
          (a, b) => a.mensagem.enviadoEm.compareTo(b.mensagem.enviadoEm),
        );
        _carregando = false;
      });
      _rolarParaBaixo();
    } on WsErroException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
        _carregando = false;
      });
    } on WsTimeoutException {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar as mensagens.';
        _carregando = false;
      });
    }
  }

  void _adicionarMensagemRecebida(MensagemComUrl mensagem) {
    if (!mounted ||
        mensagem.mensagem.conversaId != widget.conversa.conversaId) {
      return;
    }
    if (_mensagens.any((item) => item.mensagem.id == mensagem.mensagem.id)) {
      return;
    }
    setState(() => _mensagens.add(mensagem));
    _rolarParaBaixo();
  }

  Future<void> _enviar() async {
    final texto = _textoController.text.trim();
    if ((texto.isEmpty && _anexoSelecionado == null) || _enviando) return;

    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      final mensagem = await _repository.enviarMensagem(
        conversaId: widget.conversa.conversaId,
        texto: texto.isEmpty ? null : texto,
        arquivo: _anexoSelecionado?.arquivo,
      );
      if (!mounted) return;
      _textoController.clear();
      setState(() => _anexoSelecionado = null);
      _adicionarMensagemRecebida(mensagem);
    } on WsErroException catch (e) {
      if (mounted) {
        setState(() {
          _erro = ErroMapper.paraMensagem(
            e.codigo,
            mensagemServidor: e.mensagem,
          );
        });
      }
    } on WsTimeoutException {
      if (mounted) {
        setState(() => _erro = 'Não foi possível enviar a mensagem.');
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _enviarAudio(ArquivoUpload arquivo) async {
    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      final mensagem = await _repository.enviarMensagem(
        conversaId: widget.conversa.conversaId,
        arquivo: arquivo,
      );
      if (!mounted) return;
      _adicionarMensagemRecebida(mensagem);
    } on WsErroException catch (e) {
      if (mounted) {
        setState(() {
          _erro = ErroMapper.paraMensagem(
            e.codigo,
            mensagemServidor: e.mensagem,
          );
        });
      }
    } on WsTimeoutException {
      if (mounted) {
        setState(() => _erro = 'Não foi possível enviar o áudio.');
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _selecionarAnexo() async {
    final tipo = await showModalBottomSheet<_TipoAnexo>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Imagem'),
              onTap: () => Navigator.of(context).pop(_TipoAnexo.imagem),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Vídeo'),
              onTap: () => Navigator.of(context).pop(_TipoAnexo.video),
            ),
          ],
        ),
      ),
    );

    if (tipo == null || !mounted) return;

    final arquivo = tipo == _TipoAnexo.imagem
        ? await _imagePicker.pickImage(source: ImageSource.gallery)
        : await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (arquivo == null || !mounted) return;

    final bytes = await arquivo.readAsBytes();
    if (!mounted) return;
    if (bytes.isEmpty) {
      setState(() => _erro = 'Não foi possível ler o arquivo selecionado.');
      return;
    }
    if (bytes.length > 30 * 1024 * 1024) {
      setState(() => _erro = 'O arquivo deve ter no máximo 30 MB.');
      return;
    }

    final partes = arquivo.name.split('.');
    final extensao = partes.length > 1 ? partes.last.toLowerCase() : '';
    const extensoesImagem = {'png', 'jpg', 'jpeg', 'webp'};
    const extensoesVideo = {'mp4', 'webm'};
    final extensaoValida = tipo == _TipoAnexo.imagem
        ? extensoesImagem.contains(extensao)
        : extensoesVideo.contains(extensao);

    if (!extensaoValida) {
      setState(() => _erro = 'Formato de arquivo não suportado.');
      return;
    }

    setState(() {
      _erro = null;
      _anexoSelecionado = _AnexoSelecionado(
        arquivo: ArquivoUpload(
          nomeOriginal: arquivo.name,
          extensao: extensao,
          bytesBase64: base64Encode(bytes),
        ),
        tipo: tipo,
      );
    });
  }

  void _rolarParaBaixo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String _horario(DateTime data) => DateFormat('HH:mm').format(data.toLocal());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.perfilPublico,
                arguments: widget.conversa.outroUsuario.id,
              ),
              child: UserAvatar(
                avatarUrl: widget.conversa.outroUsuario.avatarUrl,
                radius: 18,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                widget.conversa.outroUsuario.nome,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          ErrorBanner(mensagem: _erro),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _mensagens.isEmpty
                ? const Center(child: Text('Comece a conversa.'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: _mensagens.length,
                    itemBuilder: (context, index) {
                      final item = _mensagens[index];
                      final minha = item.mensagem.remetenteId == _usuarioId;
                      return _BolhaMensagem(
                        mensagem: item,
                        minha: minha,
                        horario: _horario(item.mensagem.enviadoEm),
                        avatarUrl: minha
                            ? Sessao.instance.usuario?.avatarUrl
                            : widget.conversa.outroUsuario.avatarUrl,
                      );
                    },
                  ),
          ),
          _Composer(
            controller: _textoController,
            enviando: _enviando,
            anexo: _anexoSelecionado,
            onAnexar: _selecionarAnexo,
            onRemoverAnexo: () => setState(() => _anexoSelecionado = null),
            onEnviar: _enviar,
            onEnviarAudio: _enviarAudio,
          ),
        ],
      ),
    );
  }
}

enum _TipoAnexo { imagem, video }

class _AnexoSelecionado {
  final ArquivoUpload arquivo;
  final _TipoAnexo tipo;

  const _AnexoSelecionado({required this.arquivo, required this.tipo});
}

class _BolhaMensagem extends StatelessWidget {
  final MensagemComUrl mensagem;
  final bool minha;
  final String horario;
  final String? avatarUrl;

  const _BolhaMensagem({
    required this.mensagem,
    required this.minha,
    required this.horario,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final ehAudio = mensagem.mensagem.tipo == TipoConteudoMensagem.audio;

    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.fromLTRB(
          ehAudio ? 8 : 14,
          ehAudio ? 8 : 10,
          ehAudio ? 8 : 12,
          ehAudio ? 6 : 7,
        ),
        decoration: BoxDecoration(
          color: minha ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(minha ? 16 : 4),
            bottomRight: Radius.circular(minha ? 4 : 16),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _ConteudoMensagem(
              mensagem: mensagem,
              minha: minha,
              avatarUrl: avatarUrl,
            ),
            if (!ehAudio && mensagem.mensagem.texto != null)
              const SizedBox(height: 3),
            if (!ehAudio)
              Text(
                horario,
                style: TextStyle(
                  fontSize: 11,
                  color: minha ? Colors.white70 : AppColors.textoSecundario,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConteudoMensagem extends StatelessWidget {
  final MensagemComUrl mensagem;
  final bool minha;
  final String? avatarUrl;

  const _ConteudoMensagem({
    required this.mensagem,
    required this.minha,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (mensagem.mensagem.tipo == TipoConteudoMensagem.audio) {
      return _AudioMensagem(
        url: mensagem.urlArquivo,
        avatarUrl: avatarUrl,
        minha: minha,
      );
    }

    final texto = mensagem.mensagem.texto;
    final url = mensagem.urlArquivo;
    final arquivo = mensagem.mensagem.arquivo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (url != null &&
            mensagem.mensagem.tipo == TipoConteudoMensagem.imagem)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              width: 260,
              height: 220,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const SizedBox(
                      width: 260,
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    ),
              errorBuilder: (context, error, stackTrace) =>
                  _FalhaNoAnexo(nome: arquivo?.nomeOriginal),
            ),
          )
        else if (url != null &&
            mensagem.mensagem.tipo == TipoConteudoMensagem.video)
          _VideoMensagem(url: url)
        else if (arquivo != null)
          _FalhaNoAnexo(nome: arquivo.nomeOriginal)
        else if (texto == null || texto.isEmpty)
          Text(
            'Arquivo enviado',
            style: TextStyle(
              color: minha ? Colors.white : AppColors.textoTitulo,
            ),
          ),
        if (texto != null && texto.isNotEmpty) ...[
          if (url != null || arquivo != null) const SizedBox(height: 8),
          Text(
            texto,
            style: TextStyle(
              color: minha ? Colors.white : AppColors.textoTitulo,
            ),
          ),
        ],
      ],
    );
  }
}

class _FalhaNoAnexo extends StatelessWidget {
  final String? nome;

  const _FalhaNoAnexo({this.nome});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.attach_file, color: AppColors.primary),
        const SizedBox(width: 6),
        Flexible(child: Text(nome ?? 'Anexo indisponível')),
      ],
    );
  }
}

class _VideoMensagem extends StatefulWidget {
  final String url;

  const _VideoMensagem({required this.url});

  @override
  State<_VideoMensagem> createState() => _VideoMensagemState();
}

class _VideoMensagemState extends State<_VideoMensagem> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const SizedBox(
        width: 260,
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 260,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          if (!_controller.value.isPlaying)
            const CircleAvatar(
              backgroundColor: Color(0xAA000000),
              child: Icon(Icons.play_arrow, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

/// Bolha de mensagem de áudio: avatar de quem enviou, botão de play,
/// waveform do arquivo e duração — baixa o áudio pra um arquivo local
/// antes de preparar o player (audio_waveforms espera um caminho local).
class _AudioMensagem extends StatefulWidget {
  final String? url;
  final String? avatarUrl;
  final bool minha;

  const _AudioMensagem({
    required this.url,
    required this.avatarUrl,
    required this.minha,
  });

  @override
  State<_AudioMensagem> createState() => _AudioMensagemState();
}

class _AudioMensagemState extends State<_AudioMensagem> {
  final _playerController = PlayerController();
  StreamSubscription<PlayerState>? _estadoSub;
  StreamSubscription<int>? _duracaoSub;

  bool _preparado = false;
  bool _falhaAoCarregar = false;
  bool _tocando = false;
  Duration _duracaoTotal = Duration.zero;
  Duration _duracaoAtual = Duration.zero;

  @override
  void initState() {
    super.initState();
    _estadoSub = _playerController.onPlayerStateChanged.listen((estado) {
      if (!mounted) return;
      setState(() => _tocando = estado == PlayerState.playing);
    });
    _duracaoSub = _playerController.onCurrentDurationChanged.listen((ms) {
      if (!mounted) return;
      setState(() => _duracaoAtual = Duration(milliseconds: ms));
    });
    _preparar();
  }

  Future<void> _preparar() async {
    final url = widget.url;
    if (url == null) {
      setState(() => _falhaAoCarregar = true);
      return;
    }
    try {
      final caminhoLocal = await _baixarArquivoTemporario(url);
      await _playerController.preparePlayer(
        path: caminhoLocal,
        shouldExtractWaveform: true,
      );
      final duracaoMs = await _playerController.getDuration(DurationType.max);
      if (!mounted) return;
      setState(() {
        _preparado = true;
        _duracaoTotal = Duration(milliseconds: duracaoMs);
      });
    } catch (_) {
      if (mounted) setState(() => _falhaAoCarregar = true);
    }
  }

  Future<String> _baixarArquivoTemporario(String url) async {
    final resposta = await http.get(Uri.parse(url));
    final diretorio = await getTemporaryDirectory();
    final caminho =
        '${diretorio.path}/audio_${DateTime.now().microsecondsSinceEpoch}.m4a';
    await File(caminho).writeAsBytes(resposta.bodyBytes);
    return caminho;
  }

  String _formatarDuracao(Duration duracao) {
    final minutos = duracao.inMinutes.toString().padLeft(2, '0');
    final segundos = (duracao.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }

  @override
  void dispose() {
    _estadoSub?.cancel();
    _duracaoSub?.cancel();
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duracaoExibida = _duracaoAtual > Duration.zero
        ? _duracaoAtual
        : _duracaoTotal;
    final corBase = widget.minha ? Colors.white : AppColors.primary;

    return SizedBox(
      width: 240,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(avatarUrl: widget.avatarUrl, radius: 16),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _preparado
                ? () {
                    _tocando
                        ? _playerController.pausePlayer()
                        : _playerController.startPlayer();
                  }
                : null,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: widget.minha
                  ? Colors.white24
                  : AppColors.primary.withOpacity(0.1),
              child: !_preparado
                  ? (_falhaAoCarregar
                        ? Icon(Icons.error_outline, size: 16, color: corBase)
                        : SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: corBase,
                            ),
                          ))
                  : Icon(
                      _tocando ? Icons.pause : Icons.play_arrow,
                      size: 18,
                      color: corBase,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _preparado
                ? AudioFileWaveforms(
                    size: const Size(double.infinity, 32),
                    playerController: _playerController,
                    enableSeekGesture: true,
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: PlayerWaveStyle(
                      fixedWaveColor: widget.minha
                          ? Colors.white54
                          : AppColors.primary.withOpacity(0.3),
                      liveWaveColor: corBase,
                      spacing: 4,
                    ),
                  )
                : const SizedBox(height: 32),
          ),
          const SizedBox(width: 8),
          Text(
            _formatarDuracao(duracaoExibida),
            style: TextStyle(
              fontSize: 11,
              color: widget.minha ? Colors.white70 : AppColors.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatefulWidget {
  final TextEditingController controller;
  final bool enviando;
  final _AnexoSelecionado? anexo;
  final VoidCallback onAnexar;
  final VoidCallback onRemoverAnexo;
  final VoidCallback onEnviar;
  final ValueChanged<ArquivoUpload> onEnviarAudio;

  const _Composer({
    required this.controller,
    required this.enviando,
    required this.anexo,
    required this.onAnexar,
    required this.onRemoverAnexo,
    required this.onEnviar,
    required this.onEnviarAudio,
  });

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _recorderController = RecorderController();

  bool _temTexto = false;
  bool _gravando = false;
  String? _caminhoGravacaoAtual;
  Duration _duracaoGravacao = Duration.zero;
  Timer? _timerGravacao;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_aoMudarTexto);
  }

  void _aoMudarTexto() {
    final temTexto = widget.controller.text.trim().isNotEmpty;
    if (temTexto != _temTexto) setState(() => _temTexto = temTexto);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_aoMudarTexto);
    _timerGravacao?.cancel();
    _recorderController.dispose();
    super.dispose();
  }

  Future<void> _iniciarGravacao() async {
    final diretorio = await getTemporaryDirectory();
    final caminho =
        '${diretorio.path}/gravacao_${DateTime.now().microsecondsSinceEpoch}.m4a';

    await _recorderController.record(
      path: caminho,
      recorderSettings: const RecorderSettings(
        androidEncoderSettings: AndroidEncoderSettings(
          androidEncoder: AndroidEncoder.aacLc,
        ),
        iosEncoderSettings: IosEncoderSetting(
          iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
        ),
        sampleRate: 44100,
      ),
    );

    if (!mounted) return;
    setState(() {
      _gravando = true;
      _caminhoGravacaoAtual = caminho;
      _duracaoGravacao = Duration.zero;
    });
    _timerGravacao = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _duracaoGravacao += const Duration(seconds: 1));
    });
  }

  Future<void> _cancelarGravacao() async {
    _timerGravacao?.cancel();
    await _recorderController.stop();
    final caminho = _caminhoGravacaoAtual;
    if (caminho != null) {
      final arquivo = File(caminho);
      if (await arquivo.exists()) await arquivo.delete();
    }
    if (!mounted) return;
    setState(() {
      _gravando = false;
      _caminhoGravacaoAtual = null;
    });
  }

  Future<void> _confirmarGravacao() async {
    _timerGravacao?.cancel();
    final caminho = await _recorderController.stop();
    final caminhoFinal = caminho ?? _caminhoGravacaoAtual;
    if (mounted) setState(() => _gravando = false);

    if (caminhoFinal == null) return;
    final arquivo = File(caminhoFinal);
    if (!await arquivo.exists()) return;

    final bytes = await arquivo.readAsBytes();
    widget.onEnviarAudio(
      ArquivoUpload(
        nomeOriginal: 'audio.m4a',
        extensao: 'm4a',
        bytesBase64: base64Encode(bytes),
      ),
    );
    await arquivo.delete();
    if (mounted) setState(() => _caminhoGravacaoAtual = null);
  }

  String _formatarDuracao(Duration duracao) {
    final minutos = duracao.inMinutes.toString().padLeft(2, '0');
    final segundos = (duracao.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }

  @override
  Widget build(BuildContext context) {
    final podeEnviarTexto = _temTexto || widget.anexo != null;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.anexo != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.anexo!.tipo == _TipoAnexo.imagem
                          ? Icons.image_outlined
                          : Icons.videocam_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.anexo!.arquivo.nomeOriginal,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.enviando ? null : widget.onRemoverAnexo,
                      icon: const Icon(Icons.close),
                      tooltip: 'Remover anexo',
                    ),
                  ],
                ),
              ),
            if (_gravando)
              Row(
                children: [
                  IconButton(
                    onPressed: widget.enviando ? null : _cancelarGravacao,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'Cancelar gravação',
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    _formatarDuracao(_duracaoGravacao),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AudioWaveforms(
                      size: const Size(double.infinity, 36),
                      recorderController: _recorderController,
                      waveStyle: const WaveStyle(
                        waveColor: AppColors.primary,
                        extendWaveform: true,
                        showMiddleLine: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: widget.enviando ? null : _confirmarGravacao,
                    icon: const Icon(Icons.send_rounded),
                    tooltip: 'Enviar áudio',
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: widget.enviando ? null : widget.onAnexar,
                    icon: const Icon(Icons.attach_file_rounded),
                    tooltip: 'Anexar imagem ou vídeo',
                  ),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Escreva uma mensagem',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(22)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => widget.onEnviar(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: widget.enviando
                        ? null
                        : (podeEnviarTexto
                              ? widget.onEnviar
                              : _iniciarGravacao),
                    icon: widget.enviando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            podeEnviarTexto
                                ? Icons.send_rounded
                                : Icons.mic_rounded,
                          ),
                    tooltip: podeEnviarTexto
                        ? 'Enviar mensagem'
                        : 'Gravar áudio',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
