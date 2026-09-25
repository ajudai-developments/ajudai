import 'package:ajudai/features/agendamento/widgets/lista_agendamento_historico.dart';
import 'package:ajudai/features/agendamento/widgets/segmented_tab_bar.dart';
import 'package:ajudai/features/denuncia/denunciar_usuario_args.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/session/sessao.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/async_list_view.dart';
import '../servico/servico_repository.dart';
import 'agendamento_acoes.dart';
import 'agendamento_repository.dart';
import 'widgets/agendamento_com_detalhes.dart';
import 'widgets/lista_agendamentos_filtravel.dart';

class AgendamentosRecebidosScreen extends StatefulWidget {
  const AgendamentosRecebidosScreen({super.key});

  @override
  State<AgendamentosRecebidosScreen> createState() =>
      _AgendamentosRecebidosScreenState();
}

class _AgendamentosRecebidosScreenState
    extends State<AgendamentosRecebidosScreen> {
  final _agendamentoRepository = AgendamentoRepository();
  final _servicoRepository = ServicoRepository();
  int _aba = 0;

  void _abrirDetalhe(AgendamentoComDetalhes item) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.agendamentoDetalhe, arguments: item.agendamento.id);
  }

  void _abrirAvaliacao(AgendamentoComDetalhes item) {
    Navigator.of(context).pushNamed(
      item.comoPrestador
          ? AppRoutes.avaliarUsuario
          : AppRoutes.avaliarAgendamento,
      arguments: item.agendamento.id,
    );
  }

  void _abrirDenuncia(AgendamentoComDetalhes item) {
    Navigator.of(context).pushNamed(
      AppRoutes.denunciarUsuario,
      arguments: DenunciarUsuarioArgs(
        usuarioId: item.contraParteId,
        nomeUsuario: item.nomeContraparte,
      ),
    );
  }

  void _abrirContestacao(AgendamentoComDetalhes item) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.contestarAgendamento, arguments: item.agendamento.id);
  }

  Future<Agendamento> _executarAcao(
    AgendamentoComDetalhes item,
    AcaoAgendamento acao, {
    String? motivo,
  }) => executarAcaoAgendamento(
    _agendamentoRepository,
    item.agendamento.id,
    acao,
    motivo: motivo,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Agendamentos recebidos')),
      body: Column(
        children: [
          SegmentedTabBar(
            labels: const ['Ativos', 'Histórico'],
            selectedIndex: _aba,
            onChanged: (i) => setState(() => _aba = i),
          ),
          Expanded(
            child: IndexedStack(
              index: _aba,
              sizing: StackFit.expand,
              children: [
                AsyncListView<AgendamentoComDetalhes>(
                  carregar: () async {
                    final agendamentos = await _agendamentoRepository
                        .listarAgendamentosPrestador();
                    return carregarComDetalhesPrestador(
                      agendamentos,
                      _servicoRepository,
                    );
                  },
                  mensagemVazio:
                      'Você ainda não recebeu nenhum pedido de agendamento.',
                  builder: (context, itens) => ListaAgendamentosFiltravel(
                    itens: itens,
                    onTapItem: _abrirDetalhe,
                    executarAcao: _executarAcao,
                    onAvaliar: _abrirAvaliacao,
                  ),
                ),
                AsyncListView<AgendamentoComDetalhes>(
                  carregar: () async {
                    final agendamentos = await _agendamentoRepository
                        .listarHistoricoPrestador();
                    return carregarComDetalhesPrestador(
                      agendamentos,
                      _servicoRepository,
                    );
                  },
                  mensagemVazio: 'Nenhum agendamento no seu histórico ainda.',
                  builder: (context, itens) => ListaAgendamentosHistorico(
                    itens: itens,
                    onTapItem: _abrirDetalhe,
                    onAvaliar: _abrirAvaliacao,
                    onDenunciar: _abrirDenuncia,
                    onContestar: _abrirContestacao,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Sessao.instance.ehPrestador
          ? const AppBottomNav(currentIndex: 3)
          : null,
    );
  }
}
