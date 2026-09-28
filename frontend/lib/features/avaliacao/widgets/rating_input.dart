import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Input interativo de avaliação (1 a 5 estrelas inteiras).
///
/// Diferente de RatingDisplay (core/widgets), que só EXIBE uma média,
/// aqui o usuário toca pra escolher a nota. A estrela escolhida dá um
/// pequeno "pulo" e um rótulo ("Ruim" … "Excelente") aparece embaixo.
///
/// Nota: a coluna `avaliacao` no banco é double, mas a UI só oferece
/// estrelas inteiras (1 a 5) por simplicidade.
class RatingInput extends StatelessWidget {
  final int valor; // 0 = nada selecionado ainda
  final ValueChanged<int> onChanged;

  const RatingInput({super.key, required this.valor, required this.onChanged});

  static const _rotulos = [
    '',
    'Ruim',
    'Regular',
    'Bom',
    'Muito bom',
    'Excelente',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedScale(
                    scale: i == valor ? 1.2 : 1,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      i <= valor
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 44,
                      color: i <= valor
                          ? AppColors.avaliacao
                          : AppColors.outline,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 20,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Text(
              _rotulos[valor],
              key: ValueKey(valor),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textoTitulo,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
