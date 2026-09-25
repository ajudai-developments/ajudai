import 'package:ajudai/features/agendamento/widgets/agendamento_com_detalhes.dart';
import 'package:shared/shared.dart';

/// Decide se dá pra avaliar um agendamento AGORA — só faz sentido se
/// ele está concluído, ainda dentro da janela de 24h da conclusão, e a
/// pessoa ainda não terminou de avaliar tudo que cabe ao papel dela.
class AvaliacaoElegibilidade {
  final bool podeAvaliar;
  final DateTime? prazoLimite;

  const AvaliacaoElegibilidade({required this.podeAvaliar, this.prazoLimite});

  static const janela = Duration(hours: 24);

  static AvaliacaoElegibilidade calcular(
    AgendamentoComDetalhes item, {
    DateTime? agora,
  }) {
    final a = item.agendamento;

    if (a.status != StatusAgendamento.concluido || item.avaliacaoCompleta) {
      return const AvaliacaoElegibilidade(podeAvaliar: false);
    }

    final concluidoEm =
        a.horaConfirmacaoUsuario ?? a.horaConclusaoPrestador ?? a.horaFim;
    final prazo = concluidoEm.add(janela);
    final now = agora ?? DateTime.now();

    return AvaliacaoElegibilidade(
      podeAvaliar: now.isBefore(prazo),
      prazoLimite: prazo,
    );
  }
}
