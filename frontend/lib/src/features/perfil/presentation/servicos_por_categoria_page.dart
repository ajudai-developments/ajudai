// lib/src/features/servicos/presentation/servicos_por_categoria_page.dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/servicos_list.dart';

class ServicosPorCategoriaPage extends StatelessWidget {
  final String categoriaId;
  final String categoriaNome;

  const ServicosPorCategoriaPage({
    super.key,
    required this.categoriaId,
    required this.categoriaNome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoriaNome),
        elevation: 0,
        backgroundColor: AppColors.branco,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              'Serviços disponíveis',
              style: AppTextStyles.subtitulo.copyWith(
                fontSize: 14,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ServicosList(
              categoriaId: categoriaId,
              categoriaNome: categoriaNome,
            ),
          ),
        ],
      ),
    );
  }
}