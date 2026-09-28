import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Logo do Ajudaí (PNG transparente em assets/images).
///
/// Usada nas telas de login e cadastro. Se o asset não estiver declarado
/// no pubspec.yaml, mostra um ícone no lugar em vez de quebrar a tela.
class AjudaiLogo extends StatelessWidget {
  static const caminho = 'assets/images/ajudai_logo_1024_transparente.png';

  final double altura;

  const AjudaiLogo({super.key, this.altura = 96});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      caminho,
      height: altura,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      cacheHeight: (altura * 3).round(),
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.handshake_rounded,
        size: altura * 0.6,
        color: AppColors.primary,
      ),
    );
  }
}
