import 'package:ajudai/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/async_list_view.dart';
import '../servico/servico_repository.dart';
import 'agendamento_com_detalhes.dart';
import 'agendamento_detalhe_args.dart';
import 'agendamento_repository.dart';
import 'widgets/agendamento_card.dart';

class MeusAgendamentosScreen extends StatelessWidget {
  const MeusAgendamentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agendamentoRepository = AgendamentoRepository();
    final servicoRepository = ServicoRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Meus agendamentos')),
      body: AsyncListView<AgendamentoComDetalhes>(
        carregar: () async {
          final agendamentos = await agendamentoRepository
              .listarAgendamentosCliente();
          return carregarComDetalhesCliente(agendamentos, servicoRepository);
        },
        mensagemVazio: 'Você ainda não tem agendamentos.',
        builder: (context, itens) {
          final ocorrendoAgora = itens
              .where(
                (item) =>
                    item.agendamento.status == StatusAgendamento.emAndamento,
              )
              .toList();
          final marcados = itens
              .where(
                (item) =>
                    item.agendamento.status != StatusAgendamento.emAndamento,
              )
              .toList();

          return Column(
            children: [
              _SecaoAgendamentos(
                titulo: 'Agendamento ocorrendo atualmente',
                itens: ocorrendoAgora,
                mostrarVazio: false,
              ),
              if (ocorrendoAgora.isNotEmpty && marcados.isNotEmpty)
                const SizedBox(height: 24),
              _SecaoAgendamentos(
                titulo: 'Agendamentos marcados',
                itens: marcados,
                mensagemVazio: 'Você ainda não tem agendamentos marcados.',
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

class _SecaoAgendamentos extends StatelessWidget {
  final String titulo;
  final List<AgendamentoComDetalhes> itens;
  final String? mensagemVazio;
  final bool mostrarVazio;

  const _SecaoAgendamentos({
    required this.titulo,
    required this.itens,
    this.mensagemVazio,
    this.mostrarVazio = true,
  });

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty && !mostrarVazio) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(titulo, style: AppTextStyles.titulo),
        const SizedBox(height: 8),
        if (itens.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              mensagemVazio ?? 'Nenhum agendamento encontrado.',
              style: AppTextStyles.corpo,
            ),
          )
        else
          for (final item in itens) ...[
            AgendamentoCard(
              item: item,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.agendamentoDetalhe,
                arguments: AgendamentoDetalheArgs(
                  agendamentoId: item.agendamento.id,
                  comoCliente: item.comoCliente,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}
