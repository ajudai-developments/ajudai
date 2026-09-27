import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Mapeamento visual (ícone + cor) de cada categoria de serviço.
///
/// Centralizado aqui porque é usado tanto no card de categoria da Home
/// (`CategoriaCard`) quanto nos cards de "Meus serviços oferecidos" do
/// prestador — antes esse switch estava duplicado nos dois lugares.
///
/// TODO: quando existir um mapeamento oficial vindo do backend/design,
/// substituir este switch por ele.
class CategoriaVisual {
  CategoriaVisual._();

  static IconData icone(String categoria) {
    switch (categoria.trim().toLowerCase()) {
      case 'limpeza':
        return Icons.cleaning_services_rounded;
      case 'elétrica':
        return Icons.electrical_services_rounded;
      case 'hidráulica':
        return Icons.plumbing_rounded;
      case 'beleza e estética':
        return Icons.content_cut_rounded;
      case 'reformas e construção':
        return Icons.handyman_rounded;
      case 'jardinagem':
        return Icons.yard_rounded;
      case 'tecnologia':
        return Icons.devices_rounded;
      case 'aulas particulares':
        return Icons.menu_book_rounded;
      case 'pet care':
        return Icons.pets_rounded;
      case 'eventos':
        return Icons.celebration_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  static Color cor(String categoria) {
    switch (categoria.trim().toLowerCase()) {
      case 'limpeza':
        return const Color(0xFF2E9CCA);
      case 'elétrica':
        return const Color(0xFFF5A623);
      case 'hidráulica':
        return const Color(0xFF1E88E5);
      case 'beleza e estética':
        return const Color(0xFFD6336C);
      case 'reformas e construção':
        return const Color(0xFF6D4C41);
      case 'jardinagem':
        return AppColors.success;
      case 'tecnologia':
        return const Color(0xFF5E35B1);
      case 'aulas particulares':
        return const Color(0xFF00897B);
      case 'pet care':
        return const Color(0xFFEF6C00);
      case 'eventos':
        return AppColors.primary;
      default:
        return AppColors.textoSecundario;
    }
  }
}
