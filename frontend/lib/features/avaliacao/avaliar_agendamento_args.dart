/// Argumentos da tela de avaliação (avaliação é sempre OPCIONAL).
///
/// [avaliarServico] só é true quando quem está avaliando é o CLIENTE
/// (o prestador não avalia o serviço, só a pessoa).
class AvaliarAgendamentoArgs {
  final String agendamentoId;
  final String avaliadoId;
  final String nomeContraparte;
  final String? avatarContraparte;
  final String papelContraparte; // 'Prestador' ou 'Cliente'
  final bool avaliarServico;
  final String nomeServico;

  const AvaliarAgendamentoArgs({
    required this.agendamentoId,
    required this.avaliadoId,
    required this.nomeContraparte,
    this.avatarContraparte,
    required this.papelContraparte,
    required this.avaliarServico,
    required this.nomeServico,
  });
}
