import 'package:ajudai/core/layout/responsivo.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/widgets/async_list_view.dart';
import '../../core/widgets/categoria_card.dart';
import '../../core/widgets/tela_adaptativa.dart';
import 'servico_repository.dart';

class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  void _abrirServicosDaCategoria(BuildContext context, Categoria categoria) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.servicosLista, arguments: categoria);
  }

  int _colunas(BuildContext context) => switch (context.tipoTela) {
    TipoTela.mobile => 2,
    TipoTela.tablet => 3,
    TipoTela.desktop => 4,
  };

  @override
  Widget build(BuildContext context) {
    final larguraWeb = context.usaLayoutWeb;

    return TelaAdaptativa(
      titulo: 'Categorias',
      rotaAtual: AppRoutes.categorias,
      child: AsyncListView<Categoria>(
        carregar: ServicoRepository().listarCategorias,
        mensagemVazio: 'Nenhuma categoria disponível no momento.',
        builder: (context, categorias) => ConteudoCentralizado(
          larguraMax: 1100,
          child: Padding(
            padding: EdgeInsets.all(larguraWeb ? 32 : 0),
            child: GridView.count(
              crossAxisCount: _colunas(context),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: larguraWeb ? 20 : 12,
              crossAxisSpacing: larguraWeb ? 20 : 12,
              childAspectRatio: context.ehMobile ? 1.2 : 1.35,
              children: [
                for (final categoria in categorias)
                  CategoriaCard(
                    categoria: categoria,
                    onTap: () => _abrirServicosDaCategoria(context, categoria),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
