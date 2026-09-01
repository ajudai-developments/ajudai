import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const titulo = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.pretoForte,
    height: 1.2,
  );

  static const subtitulo = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.cinzaEscuro,
    height: 1.4,
  );

  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.cinzaEscuro,
  );

  static const corpo = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.pretoForte,
  );

  static const secundario = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.cinzaClaro,
  );

  static const botao = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.branco,
  );

  static const link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.vermelho,
  );
}
