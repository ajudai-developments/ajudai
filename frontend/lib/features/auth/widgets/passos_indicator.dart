import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Barra de progresso em segmentos ("Passo 1 de 3") do fluxo de cadastro.
///
/// [atual] começa em 0. Os segmentos até o passo atual ficam vermelhos.
class PassosIndicador extends StatelessWidget {
  final int total;
  final int atual;
  final EdgeInsetsGeometry padding;

  const PassosIndicador({
    super.key,
    required this.total,
    required this.atual,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < total; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 4,
                    margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: i <= atual ? AppColors.primary : AppColors.outline,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Passo ${atual + 1} de $total', style: AppTextStyles.legenda),
        ],
      ),
    );
  }
}
