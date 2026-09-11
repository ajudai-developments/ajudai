import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_list_view.dart';
import '../servico/servico_repository.dart';
import 'agendamento_com_detalhes.dart';
import 'agendamento_repository.dart';
import 'widgets/agendamento_card.dart';

/// Visão do prestador: agendamentos que clientes pediram pra ele.
///
/// Diferente de meus_agendamentos_screen, aqui `comoCliente: false` —
/// o card mostra "Cliente" como placeholder no lugar do nome de quem
/// pediu, porque não existe endpoint pra obter nome de usuário por id
/// ainda (ver agendamento_com_detalhes.dart).
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
          final agendamentos =
              await agendamentoRepository.listarAgendamentosRecebidos();
          return carregarAgendamentosComDetalhes(
            agendamentos,
            servicoRepository,
            comoCliente: false,
          );
        },
        mensagemVazio: 'Você ainda não recebeu nenhum pedido de agendamento.',
        builder: (context, itens) => Column(
          children: [
            for (final item in itens)
              AgendamentoCard(
                item: item,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.agendamentoDetalhe,
                  arguments: item.agendamento.id,
                ),
              ),
          ],
        ),
      ),
    );
  }
}