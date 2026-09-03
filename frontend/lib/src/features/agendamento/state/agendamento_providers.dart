// lib/src/features/agendamento/state/agendamento_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../../ws/ws_client_provider.dart';
import '../data/agendamento_repository.dart';
import '../../endereco/data/endereco_repository.dart';

final agendamentoRepositoryProvider = Provider<AgendamentoRepository>((ref) {
  final wsClient = ref.watch(wsClientProvider);
  return AgendamentoRepository(wsClient);
});

final enderecoRepositoryProvider = Provider<EnderecoRepository>((ref) {
  final wsClient = ref.watch(wsClientProvider);
  return EnderecoRepository(wsClient);
});

// Provider para buscar serviços oferecidos por serviço
final servicosOferecidosProvider = FutureProvider.family<
  List<ServicoOferecidoPreview>, String
>((ref, servicoId) async {
  final repository = ref.watch(agendamentoRepositoryProvider);
  // TODO: Implementar método específico no backend
  // Por enquanto, retornamos uma lista vazia
  return [];
});

// Provider para buscar detalhes do serviço oferecido
final servicoOferecidoDetalheProvider = FutureProvider.family<
  ObterServicoOferecidoResponseDto, String
>((ref, servicoOferecidoId) async {
  final repository = ref.watch(agendamentoRepositoryProvider);
  return repository.obterServicoOferecido(servicoOferecidoId);
});

// Provider para buscar endereços do usuário
final meusEnderecosProvider = FutureProvider<List<Endereco>>((ref) async {
  final repository = ref.watch(enderecoRepositoryProvider);
  return repository.obterMeusEnderecos();
});

// Provider para criar agendamento
final criarAgendamentoProvider = FutureProvider.family<
  CriarAgendamentoResponseDto, ({
    String servicoOferecidoId,
    String enderecoId,
    DateTime horaInicio,
    DateTime horaFim,
  })
>((ref, params) async {
  final repository = ref.watch(agendamentoRepositoryProvider);
  return repository.criarAgendamento(
    servicoOferecidoId: params.servicoOferecidoId,
    enderecoId: params.enderecoId,
    horaInicio: params.horaInicio,
    horaFim: params.horaFim,
  );
});