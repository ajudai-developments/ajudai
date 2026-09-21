import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_list_view.dart';
import '../servico/servico_repository.dart';
import 'agendamento_com_detalhes.dart';
import 'agendamento_detalhe_args.dart';
import 'agendamento_repository.dart';
import 'widgets/agendamento_card.dart';

/// Visão do prestador: agendamentos que clientes pediram pra ele.
///
/// Usa `listarAgendamentosPrestador`, que já vem com `clienteNome`
/// pronto — sem chamada extra pra isso.
class AgendamentosRecebidosScreen extends StatelessWidget {
  const AgendamentosRecebidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agendamentoRepository = AgendamentoRepository();
    final servicoRepository = ServicoRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Agendamentos recebidos')),
      body: AsyncListView<AgendamentoComDetalhes>(
        carregar: () async {
          final agendamentos = await agendamentoRepository
              .listarAgendamentosPrestador();
          return carregarComDetalhesPrestador(agendamentos, servicoRepository);
        },
        mensagemVazio: 'Você ainda não recebeu nenhum pedido de agendamento.',
        builder: (context, itens) => Column(
          children: [
            for (final item in itens)
              AgendamentoCard(
                item: item,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.agendamentoDetalhe,
                  arguments: AgendamentoDetalheArgs(
                    agendamentoId: item.agendamento.id,
                    comoCliente: false,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
