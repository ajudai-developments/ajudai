import 'package:flutter/material.dart';

/// Paleta de cores do app.
class AppColors {
  AppColors._();

  // Marca
  static const Color primary = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFFC62828);
  static const Color primarySoft = Color(0xFFFDEBEA);

  static const Color success = Color(0xFF43A047);
  static const Color successSoft = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFB00020);

  /// Dourado usado especificamente em avaliações — separado de `warning`
  /// pra não misturar semântica de "alerta" com "nota".
  static const Color avaliacao = Color(0xFFF5A623);

  // Fundo e superfícies
  static const Color background = Color(0xFFF7F6F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1EFEC);
  static const Color outline = Color(0xFFEAE7E2);

  // Texto
  static const Color textoTitulo = Color(0xFF201E1C);
  static const Color textoNormal = Color(0xFF5B5854);
  static const Color textoSecundario = Color(0xFF9B968F);
}
