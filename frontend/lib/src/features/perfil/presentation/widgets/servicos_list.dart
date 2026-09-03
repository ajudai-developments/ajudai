// lib/src/features/servicos/presentation/widgets/servicos_list.dart
import 'package:ajudai/src/core/theme/app_colors.dart';
import 'package:ajudai/src/core/theme/app_text_styles.dart';
import 'package:ajudai/src/features/servicos/state/servico_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'servico_card.dart';

class ServicosList extends ConsumerWidget {
  final String? categoriaId;
  final String? categoriaNome;

  const ServicosList({
    super.key,
    this.categoriaId,
    this.categoriaNome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicosAsync = ref.watch(
      servicosPorCategoriaProvider(categoriaId),
    );

    return servicosAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.erro, size: 48),
            const SizedBox(height: 12),
            Text(
              'Erro ao carregar serviços',
              style: AppTextStyles.corpo.copyWith(
                color: AppColors.erro,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.refresh(
                servicosPorCategoriaProvider(categoriaId),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
      data: (servicos) {
        if (servicos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, color: AppColors.cinzaClaro, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Nenhum serviço encontrado',
                  style: AppTextStyles.corpo.copyWith(
                    color: AppColors.cinzaClaro,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: servicos.length,
          itemBuilder: (context, index) {
            final servico = servicos[index];
            return ServicoCard(
              servico: servico,
              onTap: () {
                // Navegar para lista de prestadores do serviço
                // ou para a tela de agendamento
                // TODO: Implementar navegação
              },
            );
          },
        );
      },
    );
  }
}