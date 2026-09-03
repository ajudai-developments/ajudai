import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../../ws/ws_client_provider.dart';
import '../data/perfil_repository.dart';
import '../../servicos/state/servico_providers.dart';

final perfilRepositoryProvider = Provider<PerfilRepository>((ref) {
  final wsClient = ref.watch(wsClientProvider);
  return PerfilRepository(wsClient);
});

final meusEnderecosProvider = FutureProvider.autoDispose<List<Endereco>>((ref) {
  return ref.watch(perfilRepositoryProvider).obterMeusEnderecos();
});

final categoriasProvider = FutureProvider<List<Categoria>>((ref) async {
  final repository = ref.watch(servicoRepositoryProvider);
  return repository.listarCategorias();
});
