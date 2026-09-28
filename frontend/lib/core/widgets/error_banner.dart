import 'package:flutter/material.dart';

import '../layout/responsivo.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Banner de erro exibido no topo de formulários/telas.
/// Recebe a mensagem já traduzida por ErroMapper.
class ErrorBanner extends StatelessWidget {
  final String? mensagem;

  const ErrorBanner({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    if (mensagem == null) return const SizedBox.shrink();

    final conteudo = Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensagem!,
              style: AppTextStyles.corpo.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );

    // No web, evita o banner esticar full-width em telas que não
    // estejam dentro de um ConteudoCentralizado.
    if (context.usaLayoutWeb) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: conteudo,
      );
    }

    return conteudo;
  }
}
