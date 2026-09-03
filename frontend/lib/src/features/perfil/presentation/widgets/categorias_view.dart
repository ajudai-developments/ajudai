// lib/src/features/perfil/presentation/widgets/categorias_view.dart
import 'package:ajudai/src/core/theme/app_colors.dart';
import 'package:ajudai/src/core/theme/app_text_styles.dart';
import 'package:ajudai/src/features/perfil/presentation/servicos_por_categoria_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../../../home/state/home_providers.dart';

class CategoriasView extends ConsumerWidget {
  const CategoriasView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);

    return categoriasAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.erro, size: 48),
            const SizedBox(height: 12),
            Text(
              'Erro ao carregar categorias',
              style: AppTextStyles.corpo.copyWith(color: AppColors.erro),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.refresh(categoriasProvider),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
      data: (categorias) {
        if (categorias.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  color: AppColors.cinzaClaro,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nenhuma categoria disponível',
                  style: AppTextStyles.corpo.copyWith(
                    color: AppColors.cinzaClaro,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return CategoriaCard(
                categoria: categoria,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServicosPorCategoriaPage(
                        categoriaId: categoria.id,
                        categoriaNome: categoria.nome,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

// lib/src/features/perfil/presentation/widgets/categoria_card.dart
class CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;

  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.vermelho.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getIconForCategory(categoria.nome),
                  color: AppColors.vermelho,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                categoria.nome,
                style: AppTextStyles.corpo.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String nome) {
    // Mapeamento simples de categorias para ícones
    final lower = nome.toLowerCase();
    if (lower.contains('elétric')) return Icons.electrical_services_rounded;
    if (lower.contains('encan')) return Icons.plumbing_rounded;
    if (lower.contains('pint')) return Icons.format_paint_rounded;
    if (lower.contains('jard')) return Icons.grass_rounded;
    if (lower.contains('limpeza')) return Icons.cleaning_services_rounded;
    if (lower.contains('construção')) return Icons.construction_rounded;
    if (lower.contains('marcen')) return Icons.handyman_rounded;
    if (lower.contains('vidro')) return Icons.window_rounded;
    if (lower.contains('reform')) return Icons.architecture_rounded;
    return Icons.category_rounded;
  }
}
