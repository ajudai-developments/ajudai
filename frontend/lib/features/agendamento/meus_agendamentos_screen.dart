import 'package:ajudai/features/agendamento/widgets/lista_agendamento_historico.dart';
import 'package:ajudai/features/agendamento/widgets/segmented_tab_bar.dart';
import 'package:ajudai/features/avaliacao/avaliar_agendamento_args.dart';
import 'package:ajudai/features/denuncia/denunciar_usuario_args.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/async_list_view.dart';
import '../servico/servico_repository.dart';
import 'agendamento_acoes.dart';
import 'agendamento_repository.dart';
import 'widgets/agendamento_com_detalhes.dart';
import 'widgets/lista_agendamentos_filtravel.dart';

class MeusAgendamentosScreen extends StatefulWidget {
  const MeusAgendamentosScreen({super.key});

  @override
  State<MeusAgendamentosScreen> createState() => _MeusAgendamentosScreenState();
}

class _MeusAgendamentosScreenState extends State<MeusAgendamentosScreen> {
  final _agendamentoRepository = AgendamentoRepository();
  final _servicoRepository = ServicoRepository();
  int _aba = 0;
  int _reloadTick = 0;

  void _abrirDetalhe(AgendamentoComDetalhes item) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.agendamentoDetalhe, arguments: item.agendamento.id);
  }

  Future<void> _abrirAvaliacao(AgendamentoComDetalhes item) async {
    final args = AvaliarAgendamentoArgs(
      agendamentoId: item.agendamento.id,
      avaliadoId: item.contraParteId,
      nomeContraparte: item.nomeContraparte,
      avatarContraparte: item.contraparteAvatarUrl,
      nomeServico: item.nomeServico,
      papelContraparte: item.comoPrestador ? 'Cliente' : 'Prestador',
      avaliarServico: item.comoCliente,
    );
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.avaliarAgendamento, arguments: args);
    if (mounted) setState(() => _reloadTick++);
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
      appBar: AppBar(title: const Text('Meus agendamentos')),
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
                  key: ValueKey('ativos-$_reloadTick'),
                  carregar: () async {
                    final agendamentos = await _agendamentoRepository
                        .listarAgendamentosCliente();
                    return carregarComDetalhesCliente(
                      agendamentos,
                      _servicoRepository,
                    );
                  },
                  mensagemVazio: 'Você ainda não tem agendamentos.',
                  builder: (context, itens) => ListaAgendamentosFiltravel(
                    itens: itens,
                    onTapItem: _abrirDetalhe,
                    executarAcao: _executarAcao,
                    onAvaliar: _abrirAvaliacao,
                  ),
                ),
                AsyncListView<AgendamentoComDetalhes>(
                  key: ValueKey('historico-$_reloadTick'),
                  carregar: () async {
                    final agendamentos = await _agendamentoRepository
                        .listarHistoricoCliente();
                    return carregarComDetalhesCliente(
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
