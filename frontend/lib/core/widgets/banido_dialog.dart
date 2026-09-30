import 'package:flutter/material.dart';

import '../session/sessao.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Bottom sheet exibido quando um usuário banido tenta acessar uma área
/// bloqueada. Quem chama decide quando abrir (ver AppBottomNav).
class BanidoDialog extends StatelessWidget {
  const BanidoDialog({super.key});

  static Future<void> mostrar(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const BanidoDialog(),
    );
  }

  /// Retorna true se o usuário pode prosseguir; se estiver banido,
  /// abre o aviso e retorna false.
  static bool exigirAtivo(BuildContext context) {
    if (!Sessao.instance.estaBanido) return true;
    mostrar(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block_rounded,
                  size: 36,
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Conta banida',
              textAlign: TextAlign.center,
              style: AppTextStyles.display.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Você está banido da plataforma e não pode mais realizar '
              'agendamentos, conversas ou outras ações.',
              textAlign: TextAlign.center,
              style: AppTextStyles.corpo,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
          ],
        ),
      ),
    );
  }
}
