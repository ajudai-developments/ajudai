import 'package:flutter/material.dart';

/// Paleta de cores do app.
class AppColors {
  AppColors._();

  // Cores principais
  static const Color primary = Color(0xFFE53935); // vermelho — ação/botão principal
  static const Color success = Color(0xFF43A047); // verde — sucesso/confirmado
  static const Color background = Color(0xFFFFFFFF); // branco — fundo

  // Textos
  static const Color textoTitulo = Color(0xFF212121); // preto forte
  static const Color textoNormal = Color(0xFF616161); // cinza escuro
  static const Color textoSecundario = Color(0xFF9E9E9E); // cinza claro

  // Ainda não definidas pela convenção — mantidas como default até
  // termos uma cor oficial de erro/aviso.
  static const Color error = Color(0xFFB00020);
  static const Color warning = Color(0xFFF9A825);
}