import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/session/sessao.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/error_banner.dart';
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
  final _textoController = TextEditingController();
  final _scrollController = ScrollController();
  final _mensagens = <MensagemComUrl>[];
  StreamSubscription<MensagemComUrl>? _novasMensagensSubscription;

  bool _carregando = true;
  bool _enviando = false;
  String? _erro;

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
      final mensagens = await _repository.listarMensagens(widget.conversa.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _mensagens
          ..clear()
          ..addAll(
            mensagens.where(
              (item) => item.mensagem.idConversa == widget.conversa.id,
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
    if (!mounted || mensagem.mensagem.idConversa != widget.conversa.id) return;
    if (_mensagens.any((item) => item.mensagem.id == mensagem.mensagem.id)) {
      return;
    }
    setState(() => _mensagens.add(mensagem));
    _rolarParaBaixo();
  }

  Future<void> _enviar() async {
    final texto = _textoController.text.trim();
    if (texto.isEmpty || _enviando) return;

    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      final mensagem = await _repository.enviarMensagem(
        conversaId: widget.conversa.id,
        texto: texto,
      );
      if (!mounted) return;
      _textoController.clear();
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
        title: Text(widget.conversa.outroUsuario.nome),
        actions: [
          if (widget.conversa.emAgendamentoAtivo)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.handshake_outlined),
            ),
        ],
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
                    itemBuilder: (context, index) => _BolhaMensagem(
                      mensagem: _mensagens[index],
                      minha:
                          _mensagens[index].mensagem.idRemetente == _usuarioId,
                      horario: _horario(_mensagens[index].mensagem.enviadoEm),
                    ),
                  ),
          ),
          _Composer(
            controller: _textoController,
            enviando: _enviando,
            onEnviar: _enviar,
          ),
        ],
      ),
    );
  }
}

class _BolhaMensagem extends StatelessWidget {
  final MensagemComUrl mensagem;
  final bool minha;
  final String horario;

  const _BolhaMensagem({
    required this.mensagem,
    required this.minha,
    required this.horario,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 7),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                mensagem.mensagem.texto ?? 'Arquivo enviado',
                style: TextStyle(
                  color: minha ? Colors.white : AppColors.textoTitulo,
                ),
              ),
            ),
            const SizedBox(height: 3),
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

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool enviando;
  final VoidCallback onEnviar;

  const _Composer({
    required this.controller,
    required this.enviando,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
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
                onSubmitted: (_) => onEnviar(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: enviando ? null : onEnviar,
              icon: enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              tooltip: 'Enviar mensagem',
            ),
          ],
        ),
      ),
    );
  }
}
