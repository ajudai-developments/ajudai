import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/categoria_visual.dart';

/// Card de categoria de serviço.
///
/// Ícone em círculo colorido (tom claro da cor da categoria) + nome
/// abaixo — sem foto de fundo, então não há problema de contraste de
/// texto sobre imagem.
///
/// Reutilizado em: home_screen (grade resumida) e categorias_screen
/// (lista completa).
class CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;

  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cor = CategoriaVisual.cor(categoria.nome);
    final icone = CategoriaVisual.icone(categoria.nome);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: cor, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              categoria.nome,
              style: AppTextStyles.label.copyWith(color: AppColors.textoTitulo),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
