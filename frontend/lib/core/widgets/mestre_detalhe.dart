import 'package:flutter/material.dart';

import '../errors/erro_mapper.dart';
import '../layout/responsivo.dart';
import '../theme/app_colors.dart';
import '../ws/ws_message_stream.dart';
import 'error_banner.dart';

/// Traduz qualquer erro de chamada WS para uma mensagem amigável.
String mensagemDeErroWs(Object e) {
  if (e is WsErroException) {
    return ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
  }
  if (e is WsTimeoutException) {
    return 'Não foi possível conectar ao servidor. Tente novamente.';
  }
  return 'Ocorreu um erro inesperado. Tente novamente.';
}

/// Layout web "mestre-detalhe": lista com filtros à esquerda, detalhe do
/// item selecionado à direita. Usado nas telas de gestão do admin.
///
/// Para trocar de filtro, o pai deve recriar este widget com uma nova
/// `key` (ex: `ValueKey(abaSelecionada)`) — isso recarrega a lista.
class MestreDetalhe<T> extends StatefulWidget {
  final Future<List<T>> Function() carregar;
  final String Function(T item) idDe;

  /// Conteúdo do card do item na lista (o container/seleção é desenhado aqui).
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Painel de detalhe. [recarregar] atualiza a lista mantendo a seleção —
  /// chamar depois de uma ação (aprovar, responder etc).
  final Widget Function(
    BuildContext context,
    T item,
    Future<void> Function() recarregar,
  )
  detalheBuilder;

  /// Chamado quando o usuário seleciona um item. Devolve o item atualizado
  /// (ex: com status novo), que substitui o original na lista sem recarregar.
  final Future<T> Function(T item)? aoAbrir;

  final Widget? filtros;
  final String mensagemVazio;
  final String mensagemSelecione;

  const MestreDetalhe({
    super.key,
    required this.carregar,
    required this.idDe,
    required this.itemBuilder,
    required this.detalheBuilder,
    required this.mensagemVazio,
    this.mensagemSelecione = 'Selecione um item na lista para ver os detalhes.',
    this.filtros,
    this.aoAbrir,
  });

  @override
  State<MestreDetalhe<T>> createState() => _MestreDetalheState<T>();
}

class _MestreDetalheState<T> extends State<MestreDetalhe<T>> {
  bool _carregando = true;
  String? _erro;
  List<T> _itens = [];
  String? _selecionadoId;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar({bool silencioso = false}) async {
    if (!silencioso) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }

    try {
      final itens = await widget.carregar();
      if (!mounted) return;
      setState(() {
        _itens = itens;
        _erro = null;
        final aindaExiste = itens.any((i) => widget.idDe(i) == _selecionadoId);
        if (!aindaExiste) _selecionadoId = null;
      });
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemDeErroWs(e));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _selecionar(T item) {
    final id = widget.idDe(item);
    if (id == _selecionadoId) return;
    setState(() => _selecionadoId = id);
    _abrir(item);
  }

  Future<void> _abrir(T item) async {
    final callback = widget.aoAbrir;
    if (callback == null) return;
    try {
      final atualizado = await callback(item);
      if (!mounted) return;
      final id = widget.idDe(item);
      setState(() {
        _itens = [
          for (final i in _itens) widget.idDe(i) == id ? atualizado : i,
        ];
      });
    } catch (_) {
      // Silencioso: o admin continua vendo o item; o status é tentado de
      // novo na próxima vez que ele abrir.
    }
  }

  T? get _selecionado {
    for (final i in _itens) {
      if (widget.idDe(i) == _selecionadoId) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 380, child: _buildLista()),
        const VerticalDivider(width: 1, color: AppColors.outline),
        Expanded(child: _buildDetalhe()),
      ],
    );
  }

  Widget _buildLista() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            children: [
              if (widget.filtros != null)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: widget.filtros!,
                  ),
                )
              else
                const Spacer(),
              IconButton(
                tooltip: 'Atualizar',
                onPressed: _carregando ? null : () => _carregar(),
                icon: const Icon(Icons.refresh_rounded),
                color: AppColors.textoSecundario,
              ),
            ],
          ),
        ),
        Expanded(
          child: _carregando && _itens.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    ErrorBanner(mensagem: _erro),
                    if (_itens.isEmpty && _erro == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Text(
                          widget.mensagemVazio,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textoSecundario,
                          ),
                        ),
                      ),
                    for (final item in _itens) _cardItem(item),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _cardItem(T item) {
    final id = widget.idDe(item);
    final sel = id == _selecionadoId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: sel ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _selecionar(item),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? AppColors.primary : AppColors.outline,
                width: sel ? 1.5 : 1,
              ),
            ),
            child: widget.itemBuilder(context, item),
          ),
        ),
      ),
    );
  }

  Widget _buildDetalhe() {
    final item = _selecionado;

    if (item == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.touch_app_outlined,
                color: AppColors.textoSecundario,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.mensagemSelecione,
              style: const TextStyle(color: AppColors.textoSecundario),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConteudoCentralizado(
        larguraMax: 820,
        child: KeyedSubtree(
          key: ValueKey(widget.idDe(item)),
          child: widget.detalheBuilder(
            context,
            item,
            () => _carregar(silencioso: true),
          ),
        ),
      ),
    );
  }
}
