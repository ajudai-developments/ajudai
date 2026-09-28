import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Seletor de abas simples pro layout web — equivalente funcional do
/// SegmentedTabBar/CabecalhoComAbas, mas sem o header vermelho de tela
/// cheia (que só faz sentido no mobile).
class AbasChipsWeb extends StatelessWidget {
  final List<String> abas;
  final int selecionada;
  final ValueChanged<int> onChanged;

  const AbasChipsWeb({
    super.key,
    required this.abas,
    required this.selecionada,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < abas.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(abas[i]),
              selected: selecionada == i,
              onSelected: (_) => onChanged(i),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceAlt,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: selecionada == i ? Colors.white : AppColors.textoNormal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide.none,
              ),
            ),
          ),
      ],
    );
  }
}
