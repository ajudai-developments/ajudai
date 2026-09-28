import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ajudai/core/routes/app_routes.dart';
import 'package:ajudai/features/conversas/camera_captura_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/session/sessao.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/user_avatar.dart';
import '../../core/ws/ws_message_stream.dart';
import 'conversas_repository.dart';
import 'widgets/anexo_selecionado.dart';
import 'widgets/bolha_mensagem.dart';
import 'widgets/composer.dart';

class ConversaScreen extends StatefulWidget {
  final ConversaResumo conversa;

  const ConversaScreen({required this.conversa, super.key});

  @override
  State<ConversaScreen> createState() => _ConversaScreenState();
}

const _maxAnexos = 5;
const _limiteBytes = 30 * 1024 * 1024;
const _extensoesImagem = {'png', 'jpg', 'jpeg', 'webp'};
const _extensoesVideo = {'mp4', 'webm', 'mov'};

String _codificarArquivoBase64(String caminho) =>
    base64Encode(File(caminho).readAsBytesSync());

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
  final _anexos = <AnexoSelecionado>[];

  String? get _usuarioId => Sessao.instance.usuario?.id;

  @override
  void initState() {
    super.initState();
    _carregarMensagens();
    _novasMensagensSubscription = _repository.escutarNovasMensagens().listen(
      _adicionarMensagemRecebida,
    );
  }

  Future<void> _abrirCamera() async {
    if (_anexos.length >= _maxAnexos) {
      setState(
        () =>
            _erro = 'Você pode enviar no máximo $_maxAnexos arquivos por vez.',
      );
      return;
    }
    final permissoes = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    final camera = permissoes[Permission.camera]!;
    final microfone = permissoes[Permission.microphone]!;
    if (!mounted) return;

    if (!camera.isGranted) {
      if (camera.isPermanentlyDenied) {
        await _dialogoAbrirConfiguracoes();
      } else {
        setState(() => _erro = 'É preciso permitir o uso da câmera.');
      }
      return;
    }

    final resultado = await Navigator.of(context).push<CapturaResultado>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            CameraCapturaScreen(gravarComAudio: microfone.isGranted),
      ),
    );
    if (resultado == null || !mounted) return;

    await _adicionarArquivos([resultado.arquivo]);
  }

  Future<void> _dialogoAbrirConfiguracoes() async {
    final abrir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão necessária'),
        content: const Text(
          'Para usar a câmera, permita o acesso nas configurações do aparelho.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Abrir configurações'),
          ),
        ],
      ),
    );
    if (abrir == true) await openAppSettings();
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
      if (!mounted) return;
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
    if ((texto.isEmpty && _anexos.isEmpty) || _enviando) return;

    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      if (_anexos.isEmpty) {
        final mensagem = await _repository.enviarMensagem(
          conversaId: widget.conversa.conversaId,
          texto: texto,
        );
        if (!mounted) return;
        _textoController.clear();
        _adicionarMensagemRecebida(mensagem);
      } else {
        final pendentes = List.of(_anexos);
        for (var i = 0; i < pendentes.length; i++) {
          final anexo = pendentes[i];
          final base64 = await compute(_codificarArquivoBase64, anexo.caminho);

          final mensagem = await _repository.enviarMensagem(
            conversaId: widget.conversa.conversaId,
            // a legenda vai só com o primeiro arquivo
            texto: (i == 0 && texto.isNotEmpty) ? texto : null,
            arquivo: ArquivoUpload(
              nomeOriginal: anexo.nomeOriginal,
              extensao: anexo.extensao,
              bytesBase64: base64,
            ),
          );
          if (!mounted) return;
          if (i == 0) _textoController.clear();
          setState(() => _anexos.remove(anexo));
          _adicionarMensagemRecebida(mensagem);
        }
      }
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
    final restante = _maxAnexos - _anexos.length;
    if (restante <= 0) {
      setState(
        () =>
            _erro = 'Você pode enviar no máximo $_maxAnexos arquivos por vez.',
      );
      return;
    }

    final List<XFile> arquivos;
    if (restante == 1) {
      final unico = await _imagePicker.pickMedia();
      arquivos = unico == null ? const [] : [unico];
    } else {
      arquivos = await _imagePicker.pickMultipleMedia(limit: restante);
    }
    if (arquivos.isEmpty || !mounted) return;

    await _adicionarArquivos(arquivos);
  }

  Future<({AnexoSelecionado? anexo, String? erro})> _validarArquivo(
    XFile arquivo,
  ) async {
    final tamanho = await arquivo.length();
    if (tamanho == 0) {
      return (anexo: null, erro: 'Não foi possível ler o arquivo selecionado.');
    }
    if (tamanho > _limiteBytes) {
      return (anexo: null, erro: 'Cada arquivo deve ter no máximo 30 MB.');
    }

    final partes = arquivo.name.split('.');
    final extensao = partes.length > 1 ? partes.last.toLowerCase() : '';

    final TipoAnexo tipo;
    if (_extensoesImagem.contains(extensao)) {
      tipo = TipoAnexo.imagem;
    } else if (_extensoesVideo.contains(extensao)) {
      tipo = TipoAnexo.video;
    } else {
      return (anexo: null, erro: 'Formato de arquivo não suportado.');
    }

    return (
      anexo: AnexoSelecionado(
        nomeOriginal: arquivo.name,
        extensao: extensao,
        tipo: tipo,
        caminho: arquivo.path,
      ),
      erro: null,
    );
  }

  Future<void> _adicionarArquivos(List<XFile> arquivos) async {
    final restante = _maxAnexos - _anexos.length;
    final novos = <AnexoSelecionado>[];
    String? erro;

    for (final arquivo in arquivos.take(restante)) {
      final repetido =
          _anexos.any((a) => a.caminho == arquivo.path) ||
          novos.any((a) => a.caminho == arquivo.path);
      if (repetido) continue;

      final resultado = await _validarArquivo(arquivo);
      if (resultado.anexo != null) {
        novos.add(resultado.anexo!);
      } else {
        erro = resultado.erro;
      }
    }
    if (arquivos.length > restante) {
      erro = 'Você pode enviar no máximo $_maxAnexos arquivos por vez.';
    }

    if (!mounted) return;
    setState(() {
      _anexos.addAll(novos);
      _erro = erro;
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

  bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// "Hoje", "Ontem" ou dd/MM/aaaa — usado no separador de dias.
  String _rotuloDia(DateTime data) {
    final agora = DateTime.now();
    if (_mesmoDia(data, agora)) return 'Hoje';
    if (_mesmoDia(data, agora.subtract(const Duration(days: 1)))) {
      return 'Ontem';
    }
    return DateFormat('dd/MM/yyyy').format(data);
  }

  void _abrirPerfil() {
    Navigator.of(context).pushNamed(
      AppRoutes.perfilPublico,
      arguments: widget.conversa.outroUsuario.id,
    );
  }

  Widget _construirMensagem(int index) {
    final item = _mensagens[index];
    final minha = item.mensagem.remetenteId == _usuarioId;
    final data = item.mensagem.enviadoEm.toLocal();
    final anterior = index > 0
        ? _mensagens[index - 1].mensagem.enviadoEm.toLocal()
        : null;
    final novoDia = anterior == null || !_mesmoDia(anterior, data);

    final bolha = BolhaMensagem(
      mensagem: item,
      minha: minha,
      horario: _horario(item.mensagem.enviadoEm),
      avatarUrl: minha
          ? Sessao.instance.usuario?.avatarUrl
          : widget.conversa.outroUsuario.avatarUrl,
    );

    if (!novoDia) return bolha;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SeparadorDia(rotulo: _rotuloDia(data)),
        bolha,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final outro = widget.conversa.outroUsuario;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outline),
        ),
        title: InkWell(
          onTap: _abrirPerfil,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserAvatar(avatarUrl: outro.avatarUrl, radius: 18),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    outro.nome,
                    style: AppTextStyles.titulo,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_erro != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ErrorBanner(mensagem: _erro),
            ),
          Expanded(
            child: _carregando
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _mensagens.isEmpty
                ? _EstadoSemMensagens(nome: outro.nome)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: _mensagens.length,
                    itemBuilder: (context, index) => _construirMensagem(index),
                  ),
          ),
          Composer(
            controller: _textoController,
            enviando: _enviando,
            anexos: _anexos,
            onAnexar: _selecionarAnexo,
            onRemoverAnexo: (anexo) => setState(() => _anexos.remove(anexo)),
            onEnviar: _enviar,
            onEnviarAudio: _enviarAudio,
            onErro: (mensagem) => setState(() => _erro = mensagem),
            onCamera: _abrirCamera,
          ),
        ],
      ),
    );
  }
}

/// Chip centralizado com o dia ("Hoje", "Ontem", dd/MM/aaaa) que aparece
/// antes da primeira mensagem de cada dia.
class _SeparadorDia extends StatelessWidget {
  final String rotulo;

  const _SeparadorDia({required this.rotulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(rotulo, style: AppTextStyles.label),
        ),
      ),
    );
  }
}

class _EstadoSemMensagens extends StatelessWidget {
  final String nome;

  const _EstadoSemMensagens({required this.nome});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Comece a conversa', style: AppTextStyles.titulo),
            const SizedBox(height: 4),
            Text(
              'Envie uma mensagem para $nome.',
              textAlign: TextAlign.center,
              style: AppTextStyles.corpo,
            ),
          ],
        ),
      ),
    );
  }
}
