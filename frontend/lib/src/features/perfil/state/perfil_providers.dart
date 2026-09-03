import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../../ws/ws_client_provider.dart';
import '../data/perfil_repository.dart';

final perfilRepositoryProvider = Provider<PerfilRepository>((ref) {
  final wsClient = ref.watch(wsClientProvider);
  return PerfilRepository(wsClient);
});

final meusEnderecosProvider = FutureProvider.autoDispose<List<Endereco>>((ref) {
  return ref.watch(perfilRepositoryProvider).obterMeusEnderecos();
});