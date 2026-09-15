import 'package:flutter/material.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/async_list_view.dart';
import '../../core/ws/ws_message_stream.dart';
import '../servico/servico_repository.dart';
import 'prestador_repository.dart';
import 'servico_oferecido_com_detalhes.dart';

/// Lista os serviços que o prestador logado oferece, com ação de
/// desativar (soft delete — não existe "reativar" nem "editar" ainda).
///
/// Toque no card (fora do botão de desativar) abre o detalhe público do
/// serviço (mesma tela que um cliente veria), útil pra conferir como
/// está aparecendo.
class MeusServicosOferecidosScreen extends StatefulWidget {
  const MeusServicosOferecidosScreen({super.key});

  @override
  State<MeusServicosOferecidosScreen> createState() =>
      _MeusServicosOferecidosScreenState();
}

class _MeusServicosOferecidosScreenState
    extends State<MeusServicosOferecidosScreen> {
  final _prestadorRepository = PrestadorRepository();
  final _servicoRepository = ServicoRepository();
  final _listKey = GlobalKey<AsyncListViewState<ServicoOferecidoComDetalhes>>();

  Future<void> _confirmarEDesativar(ServicoOferecidoComDetalhes item) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desativar serviço'),
        content: Text(
          'Desativar "${item.nomeServico}"? Ele deixa de aparecer para '
          'novos clientes. Não é possível reativar depois.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;
    if (!mounted) return;

    try {
      final mensagem = await _prestadorRepository.desativarServicoOferecido(
        servicoOferecidoId: item.servicoOferecido.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
      _listKey.currentState?.recarregar();
    } on WsErroException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem),
          ),
        ),
      );
    } on WsTimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível conectar ao servidor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Meus serviços oferecidos')),
      body: AsyncListView<ServicoOferecidoComDetalhes>(
        key: _listKey,
        carregar: () async {
          final servicos = await _prestadorRepository
              .listarMeusServicosOferecidos();
          return carregarServicosOferecidosComDetalhes(
            servicos,
            _servicoRepository,
          );
        },
        mensagemVazio: 'Você ainda não tem serviços cadastrados.',
        builder: (context, itens) => Column(
          children: [
            for (final item in itens)
              Card(
                child: ListTile(
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.servicoDetalhe,
                    arguments: item.servicoOferecido.id,
                  ),
                  title: Text(item.nomeServico, style: AppTextStyles.titulo),
                  subtitle: Text(
                    '${item.nomeCategoria}\n${item.servicoOferecido.descricao}',
                    style: AppTextStyles.corpo,
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${item.servicoOferecido.valor.toStringAsFixed(2)}',
                        style: AppTextStyles.corpo,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        tooltip: 'Desativar',
                        onPressed: () => _confirmarEDesativar(item),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final resultado = await Navigator.of(
            context,
          ).pushNamed(AppRoutes.formServicoOferecido);
          if (resultado == true) _listKey.currentState?.recarregar();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar serviço'),
      ),
    );
  }
}
