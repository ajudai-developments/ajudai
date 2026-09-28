import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botão padrão do app.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}

/// Botão secundário (borda vermelha, fundo transparente), com o mesmo
/// formato e altura do [AppButton]. Usar pra ação alternativa, ao lado de
/// um AppButton principal (ex: "Criar conta" abaixo de "Entrar").
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icone;

  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: BorderSide(
        color: onPressed == null ? AppColors.outline : AppColors.primary,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );

    if (icone == null) {
      return OutlinedButton(
        onPressed: onPressed,
        style: estilo,
        child: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: estilo,
      icon: Icon(icone, size: 20),
      label: Text(label),
    );
  }
}
