import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.branco,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.vermelho,
        primary: AppColors.vermelho,
        secondary: AppColors.verde,
        surface: AppColors.branco,
        error: AppColors.erro,
      ),
      textTheme: const TextTheme(
        headlineMedium: AppTextStyles.titulo,
        bodyLarge: AppTextStyles.corpo,
        bodyMedium: AppTextStyles.subtitulo,
        labelLarge: AppTextStyles.botao,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fundoCampo,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.vermelho, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.erro, width: 1.2),
        ),
        labelStyle: AppTextStyles.label,
        hintStyle: AppTextStyles.secundario,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vermelho,
          foregroundColor: AppColors.branco,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.botao,
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.vermelho,
          textStyle: AppTextStyles.link,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.branco,
        foregroundColor: AppColors.pretoForte,
        elevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.pretoForte,
        contentTextStyle: AppTextStyles.corpo.copyWith(
          color: AppColors.branco,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
