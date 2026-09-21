import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Banner de erro exibido no topo de formulários/telas.
/// Recebe a mensagem já traduzida por ErroMapper.
class ErrorBanner extends StatelessWidget {
  final String? mensagem;

  const ErrorBanner({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    if (mensagem == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error),
      ),
      child: Text(mensagem!, style: const TextStyle(color: AppColors.error)),
    );
  }
}
