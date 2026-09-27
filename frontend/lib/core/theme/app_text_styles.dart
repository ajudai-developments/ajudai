import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Estilos de texto reutilizáveis do app.
class AppTextStyles {
  AppTextStyles._();

  /// Título de tela (cabeçalhos grandes).
  static const TextStyle display = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.2,
    color: AppColors.textoTitulo,
  );

  static const TextStyle titulo = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textoTitulo,
  );

  static const TextStyle corpo = TextStyle(
    fontSize: 14,
    height: 1.4,
    color: AppColors.textoNormal,
  );

  static const TextStyle legenda = TextStyle(
    fontSize: 12,
    color: AppColors.textoSecundario,
  );

  /// Preço em destaque nos cards de serviço.
  static const TextStyle preco = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.primary,
  );

  /// Rótulos curtos (abas, chips, badges).
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textoNormal,
  );
}
