import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final bool visivel;
  final Widget child;

  const LoadingOverlay({super.key, required this.visivel, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (visivel)
          Positioned.fill(
            child: Container(
              color: AppColors.pretoForte.withValues(alpha: 0.25),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.vermelho),
              ),
            ),
          ),
      ],
    );
  }
}
