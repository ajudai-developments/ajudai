import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool carregando;
  final bool secundario;

  const AppButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.carregando = false,
    this.secundario = false,
  });

  @override
  Widget build(BuildContext context) {
    final habilitado = onPressed != null && !carregando;

    return ElevatedButton(
      onPressed: habilitado ? onPressed : null,
      style: secundario
          ? ElevatedButton.styleFrom(
              backgroundColor: AppColors.verde,
              foregroundColor: AppColors.branco,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            )
          : null,
      child: carregando
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation(AppColors.branco),
              ),
            )
          : Text(texto),
    );
  }
}
