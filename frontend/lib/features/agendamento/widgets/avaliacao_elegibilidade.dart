import 'package:ajudai/features/agendamento/widgets/agendamento_com_detalhes.dart';
import 'package:shared/shared.dart';

/// Decide se dá pra avaliar um agendamento AGORA:
/// - só quando ele chegou a um status "final" que faz sentido avaliar
///   (concluído, cancelado ou contestado — não pendente/aceito/em
///   andamento, que ainda estão rolando);
/// - se o status for `contestado`, só quando o atendimento realmente
///   chegou a COMEÇAR (`horaInicioReal` preenchido) — porque
///   `contestado` pode vir de qualquer status anterior, inclusive de
///   um pedido `recusado` ou `nao_concluido` que nunca aconteceu de
///   fato, e nesses casos não existe nada real pra avaliar;
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
      horaInicioReal: item.agendamento.horaInicioReal,
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
    DateTime? horaInicioReal,
    DateTime? agora,
  }) {
    if (jaAvaliado || !_statusAvaliaveis.contains(status)) {
      return const AvaliacaoElegibilidade(podeAvaliar: false);
    }

    // `contestado` pode ter vindo de QUALQUER status anterior —
    // inclusive de um pedido recusado ou não concluído que nunca
    // chegou a começar de verdade. Sem essa checagem, contestar um
    // agendamento assim liberava a avaliação do nada.
    if (status == StatusAgendamento.contestado && horaInicioReal == null) {
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
