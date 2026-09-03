// lib/src/features/agendamento/presentation/prestadores_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../state/agendamento_providers.dart';
import 'agendamento_page.dart';
import 'widgets/prestador_card.dart';

class PrestadoresPage extends ConsumerWidget {
  final Servico servico;

  const PrestadoresPage({
    super.key,
    required this.servico,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestadoresAsync = ref.watch(
      servicosOferecidosProvider(servico.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(servico.nome),
        elevation: 0,
      ),
      body: prestadoresAsync.when(
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
                'Erro ao carregar prestadores',
                style: AppTextStyles.corpo.copyWith(
                  color: AppColors.erro,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(
                  servicosOferecidosProvider(servico.id),
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (prestadores) {
          if (prestadores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, color: AppColors.cinzaClaro, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum prestador disponível',
                    style: AppTextStyles.corpo.copyWith(
                      color: AppColors.cinzaClaro,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prestadores.length,
            itemBuilder: (context, index) {
              final prestador = prestadores[index];
              return PrestadorCard(
                servicoOferecido: prestador,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AgendamentoPage(
                        servicoOferecido: prestador,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}