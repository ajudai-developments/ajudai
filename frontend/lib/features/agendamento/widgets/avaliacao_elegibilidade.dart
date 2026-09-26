import 'package:ajudai/features/agendamento/widgets/agendamento_com_detalhes.dart';
import 'package:shared/shared.dart';

/// Decide se dá pra avaliar um agendamento AGORA:
/// - só quando ele chegou a um status "final" que faz sentido avaliar
///   (concluído, cancelado ou contestado — não pendente/aceito/em
///   andamento, que ainda estão rolando);
/// - só depois que o horário de INÍCIO marcado já passou (não faz
///   sentido pedir avaliação de algo que nem chegou a começar, mesmo
///   que tenha sido cancelado bem antes disso);
/// - só dentro da janela de 24h a partir desse horário de início;
/// - e só se a pessoa ainda não terminou de avaliar tudo que cabe ao
///   papel dela.
class AvaliacaoElegibilidade {
  final bool podeAvaliar;
  final DateTime? prazoLimite;

  const AvaliacaoElegibilidade({required this.podeAvaliar, this.prazoLimite});

  static const janela = Duration(hours: 24);

  static const _statusAvaliaveis = {
    StatusAgendamento.concluido,
    StatusAgendamento.cancelado,
    StatusAgendamento.contestado,
  };

  static AvaliacaoElegibilidade calcular(
    AgendamentoComDetalhes item, {
    DateTime? agora,
  }) {
    return calcularDe(
      status: item.agendamento.status,
      horaInicio: item.agendamento.horaInicio,
      jaAvaliado: item.avaliacaoCompleta,
      agora: agora,
    );
  }

  /// Versão que não depende de [AgendamentoComDetalhes] — usada na tela
  /// de detalhes, que trabalha direto com os campos soltos de
  /// `AgendamentoDetalhado`.
  static AvaliacaoElegibilidade calcularDe({
    required StatusAgendamento status,
    required DateTime horaInicio,
    required bool jaAvaliado,
    DateTime? agora,
  }) {
    if (jaAvaliado || !_statusAvaliaveis.contains(status)) {
      return const AvaliacaoElegibilidade(podeAvaliar: false);
    }

    final prazo = horaInicio.add(janela);
    final now = agora ?? DateTime.now();

    return AvaliacaoElegibilidade(
      podeAvaliar: now.isAfter(horaInicio) && now.isBefore(prazo),
      prazoLimite: prazo,
    );
  }
}
