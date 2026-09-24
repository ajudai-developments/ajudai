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
                      return BolhaMensagem(
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
