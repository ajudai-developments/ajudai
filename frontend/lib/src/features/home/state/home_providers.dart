import 'package:ajudai/src/features/categoria/data/categoria_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../../ws/ws_client_provider.dart';


final categoriaRepositoryProvider = Provider<CategoriaRepository>((ref) {
  final wsClient = ref.watch(wsClientProvider);
  return CategoriaRepository(wsClient);
});

final categoriasProvider = FutureProvider<List<Categoria>>((ref) {
  return ref.watch(categoriaRepositoryProvider).listarCategorias();
});