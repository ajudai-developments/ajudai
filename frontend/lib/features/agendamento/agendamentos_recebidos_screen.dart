import 'package:ajudai/features/agendamento/widgets/lista_agendamentos_filtravel.dart';
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/session/sessao.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/async_list_view.dart';
import '../servico/servico_repository.dart';
import 'agendamento_acoes.dart';
import 'agendamento_repository.dart';
import 'widgets/agendamento_com_detalhes.dart';

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
        builder: (context, itens) => ListaAgendamentosFiltravel(
          itens: itens,
          onTapItem: (item) => Navigator.of(context).pushNamed(
            AppRoutes.agendamentoDetalhe,
            arguments: item.agendamento.id,
          ),
          executarAcao: (item, acao, {motivo}) => executarAcaoAgendamento(
            agendamentoRepository,
            item.agendamento.id,
            acao,
            motivo: motivo,
          ),
          onAvaliar: (item) => Navigator.of(context).pushNamed(
            AppRoutes.avaliarAgendamento,
            arguments: item.agendamento.id,
          ),
        ),
      ),
      bottomNavigationBar: Sessao.instance.ehPrestador
          ? const AppBottomNav(currentIndex: 3)
          : null,
    );
  }
}
