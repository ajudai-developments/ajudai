import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;

  const CategoriaCard({super.key, required this.categoria, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fundoCampo,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.vermelho.withOpacity(0.1),
                child: Text(
                  categoria.nome.isNotEmpty ? categoria.nome[0].toUpperCase() : '?',
                  style: AppTextStyles.titulo.copyWith(
                    color: AppColors.vermelho,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                categoria.nome,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.corpo.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}