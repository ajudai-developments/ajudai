import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Estilos de texto reutilizáveis do app.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle titulo = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textoTitulo,
  );

  static const TextStyle corpo = TextStyle(
    fontSize: 14,
    color: AppColors.textoNormal,
  );

  static const TextStyle legenda = TextStyle(
    fontSize: 12,
    color: AppColors.textoSecundario,
  );
}
