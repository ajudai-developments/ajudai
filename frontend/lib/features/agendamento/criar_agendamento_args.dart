/// Dados passados para `criar_agendamento_screen` via argumento de rota.
///
/// Existe porque o backend passou a exigir `prestadorId` explícito em
/// `criarAgendamento`/`confirmarPagamento`, não só `servicoOferecidoId`.
class CriarAgendamentoArgs {
  final String servicoOferecidoId;
  final String prestadorId;

  CriarAgendamentoArgs({
    required this.servicoOferecidoId,
    required this.prestadorId,
  });
}