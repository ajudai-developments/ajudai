// Provider para o repository
// lib/src/features/servicos/state/servico_providers.dart
import 'package:ajudai/src/features/servico/data/servico_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../../ws/ws_client_provider.dart';

final servicoRepositoryProvider = Provider<ServicoRepository>((ref) {
  final wsClient = ref.watch(wsClientProvider);
  return ServicoRepository(wsClient);
});

final servicosPorCategoriaProvider =
    FutureProvider.family<List<ServicoOferecidoPreview>, String?>((
      ref,
      categoriaId,
    ) async {
      final repository = ref.watch(servicoRepositoryProvider);
      return await repository.listarServicos(categoriaId: categoriaId);
    });
