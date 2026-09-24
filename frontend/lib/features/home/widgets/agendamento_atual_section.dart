import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../agendamento/agendamento_com_detalhes.dart';
import '../../agendamento/agendamento_detalhe_args.dart';
import '../../agendamento/widgets/agendamento_card.dart';
import '../home_repository.dart';

class AgendamentoAtualSection extends StatefulWidget {
  const AgendamentoAtualSection({super.key});

  @override
  State<AgendamentoAtualSection> createState() =>
      _AgendamentoAtualSectionState();
}

class _AgendamentoAtualSectionState extends State<AgendamentoAtualSection> {
  final _homeRepository = HomeRepository();

  bool _carregando = true;
  AgendamentoComDetalhes? _agendamentoAtual;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
    });

    try {
      final atual = await _homeRepository.obterAgendamentoAtual();
      if (!mounted) return;
      setState(() => _agendamentoAtual = atual);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final agendamento = _agendamentoAtual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Agendamento ocorrendo agora', style: AppTextStyles.titulo),
        const SizedBox(height: 8),
        if (_carregando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (agendamento == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Nenhum agendamento em andamento no momento.',
              style: AppTextStyles.corpo,
            ),
          )
        else
          AgendamentoCard(
            item: agendamento,
            onTap: () {
              Navigator.of(context)
                  .pushNamed(
                    AppRoutes.agendamentoDetalhe,
                    arguments: AgendamentoDetalheArgs(
                      agendamentoId: agendamento.agendamento.id,
                      comoCliente: agendamento.comoCliente,
                    ),
                  )
                  .then((_) {
                    if (mounted) {
                      _carregar();
                    }
                  });
            },
          ),
      ],
    );
  }
}
