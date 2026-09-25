import 'package:ajudai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SeletorDataAgendamento extends StatelessWidget {
  final DateTime dataSelecionada;
  final ValueChanged<DateTime> onSelecionar;
  final int diasFuturos;

  const SeletorDataAgendamento({
    required this.dataSelecionada,
    required this.onSelecionar,
    this.diasFuturos = 30,
    super.key,
  });

  static const _nomesDiaSemana = [
    'seg',
    'ter',
    'qua',
    'qui',
    'sex',
    'sáb',
    'dom',
  ];
  static const _nomesMes = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: diasFuturos + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final dia = hojeSemHora.add(Duration(days: index));
          final selecionado = _mesmoDia(dia, dataSelecionada);
          final ehHoje = index == 0;

          return GestureDetector(
            onTap: () => onSelecionar(dia),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 56,
              decoration: BoxDecoration(
                color: selecionado ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selecionado
                      ? AppColors.primary
                      : const Color(0xFFE3E3E3),
                ),
                boxShadow: selecionado
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ehHoje ? 'hoje' : _nomesDiaSemana[dia.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selecionado ? Colors.white70 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dia.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selecionado ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    _nomesMes[dia.month - 1],
                    style: TextStyle(
                      fontSize: 10.5,
                      color: selecionado ? Colors.white70 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
