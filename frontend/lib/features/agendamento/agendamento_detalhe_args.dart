/// Dados passados para `agendamento_detalhe_screen` via argumento de rota.
///
/// Existe porque o backend não tem mais um `obterAgendamento` genérico —
/// virou `obterAgendamentoCliente`/`obterAgendamentoPrestador`, dois
/// endpoints diferentes. A tela precisa saber qual chamar ANTES de
/// buscar, então quem navega pra cá (meus_agendamentos_screen ou
/// agendamentos_recebidos_screen) já sabe o papel e repassa aqui.
class AgendamentoDetalheArgs {
  final String agendamentoId;
  final bool comoCliente;

  AgendamentoDetalheArgs({
    required this.agendamentoId,
    required this.comoCliente,
  });
}