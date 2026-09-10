import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_list_view.dart';
import '../../core/widgets/categoria_card.dart';
import 'servico_repository.dart';

class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  void _abrirServicosDaCategoria(BuildContext context, Categoria categoria) {
    Navigator.of(context).pushNamed(
      AppRoutes.servicosLista,
      arguments: categoria,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Categorias')),
      body: AsyncListView<Categoria>(
        carregar: ServicoRepository().listarCategorias,
        mensagemVazio: 'Nenhuma categoria disponível no momento.',
        builder: (context, categorias) => GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            for (final categoria in categorias)
              CategoriaCard(
                categoria: categoria,
                onTap: () => _abrirServicosDaCategoria(context, categoria),
              ),
          ],
        ),
      ),
    );
  }
}