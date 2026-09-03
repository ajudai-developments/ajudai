import 'package:ajudai/src/features/auth/presentation/widgets/categoria_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../home/state/home_providers.dart';

class CategoriasView extends ConsumerWidget {
  const CategoriasView({super.key});

  void _abrirCategoria(BuildContext context, Categoria categoria) {
    // TODO: navegar para a listagem de serviços da categoria
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Serviços de "${categoria.nome}" em breve')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(categoriasProvider);
        await ref.read(categoriasProvider.future);
      },
      child: categoriasAsync.when(
        data: (categorias) {
          if (categorias.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Nenhuma categoria disponível no momento.')),
              ],
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: categorias.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return CategoriaCard(
                categoria: categoria,
                onTap: () => _abrirCategoria(context, categoria),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erro, _) => ListView(
          children: [
            const SizedBox(height: 80),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Não foi possível carregar as categorias.\n$erro',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitulo,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => ref.invalidate(categoriasProvider),
                child: const Text('Tentar novamente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}