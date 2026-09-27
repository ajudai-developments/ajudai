import 'package:shared/shared.dart';

class EstatisticasServicoOferecido {
  final int totalAgendamentos;
  final int agendamentosEmAndamento;
  final int agendamentosConcluidos;
  final int agendamentosCancelados;
  final double faturamentoTotal;
  final double? mediaAvaliacao;
  final int quantidadeAvaliacoes;

  EstatisticasServicoOferecido({
    required this.totalAgendamentos,
    required this.agendamentosEmAndamento,
    required this.agendamentosConcluidos,
    required this.agendamentosCancelados,
    required this.faturamentoTotal,
    this.mediaAvaliacao,
    required this.quantidadeAvaliacoes,
  });

  factory EstatisticasServicoOferecido.fromJson(Map<String, dynamic> json) {
    return EstatisticasServicoOferecido(
      totalAgendamentos: JsonUtils.requireInt(json, 'total_agendamentos'),
      agendamentosEmAndamento: JsonUtils.requireInt(
        json,
        'agendamentos_em_andamento',
      ),
      agendamentosConcluidos: JsonUtils.requireInt(
        json,
        'agendamentos_concluidos',
      ),
      agendamentosCancelados: JsonUtils.requireInt(
        json,
        'agendamentos_cancelados',
      ),
      faturamentoTotal: JsonUtils.requireDouble(json, 'faturamento_total'),
      mediaAvaliacao: JsonUtils.optionalDouble(json, 'media_avaliacao'),
      quantidadeAvaliacoes: JsonUtils.requireInt(json, 'quantidade_avaliacoes'),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_agendamentos': totalAgendamentos,
    'agendamentos_em_andamento': agendamentosEmAndamento,
    'agendamentos_concluidos': agendamentosConcluidos,
    'agendamentos_cancelados': agendamentosCancelados,
    'faturamento_total': faturamentoTotal,
    'media_avaliacao': mediaAvaliacao,
    'quantidade_avaliacoes': quantidadeAvaliacoes,
  };
}
