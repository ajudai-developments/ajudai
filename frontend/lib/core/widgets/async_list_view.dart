import 'package:ajudai/core/theme/app_colors.dart';
import 'package:ajudai/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../errors/erro_mapper.dart';
import '../ws/ws_message_stream.dart';
import 'error_banner.dart';

/// Lista genérica que encapsula o padrão repetido nas telas de listagem
/// do app: carregar dados assíncronos, mostrar loading, traduzir erro
/// (WsErroException/WsTimeoutException) via ErroMapper, mostrar mensagem
/// de vazio, e permitir puxar pra atualizar (RefreshIndicator).
///
/// Não decide o layout dos itens — `builder` recebe a lista já carregada
/// e devolve o widget final (uma Column de Cards, um GridView, etc),
/// então serve tanto pra listas simples quanto grades.
///
/// Não é reativo: não escuta nada de fora. Pra recarregar de fora desta
/// classe (ex: depois de voltar de um formulário de criação/edição), use
/// uma GlobalKey<AsyncListViewState<T>> e chame `key.currentState?.recarregar()`.
class AsyncListView<T> extends StatefulWidget {
  final Future<List<T>> Function() carregar;
  final Widget Function(BuildContext context, List<T> dados) builder;
  final String mensagemVazio;

  /// Chamado sempre que `carregar` termina com sucesso. Útil quando a
  /// tela que envolve esta lista precisa saber algo sobre os dados (ex:
  /// a contagem, pra habilitar/desabilitar um botão fora da lista) sem
  /// duplicar a chamada de rede.
  final void Function(List<T> dados)? onDadosCarregados;

  const AsyncListView({
    super.key,
    required this.carregar,
    required this.builder,
    required this.mensagemVazio,
    this.onDadosCarregados,
  });

  @override
  State<AsyncListView<T>> createState() => AsyncListViewState<T>();
}

class AsyncListViewState<T> extends State<AsyncListView<T>> {
  bool _carregando = true;
  String? _erro;
  List<T> _dados = [];

  @override
  void initState() {
    super.initState();
    recarregar();
  }

  Future<void> recarregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final dados = await widget.carregar();
      if (mounted) setState(() => _dados = dados);
      widget.onDadosCarregados?.call(dados);
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
        setState(() {
          _erro = 'Não foi possível conectar ao servidor. Tente novamente.';
        });
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: recarregar,
      child: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                ErrorBanner(mensagem: _erro),
                if (_dados.isEmpty && _erro == null)
                  _EstadoVazio(mensagem: widget.mensagemVazio)
                else
                  widget.builder(context, _dados),
              ],
            ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  final String mensagem;
  const _EstadoVazio({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              color: AppColors.textoSecundario,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: AppTextStyles.corpo,
          ),
        ],
      ),
    );
  }
}
