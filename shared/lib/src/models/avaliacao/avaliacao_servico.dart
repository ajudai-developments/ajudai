import 'package:shared/src/dto/json_utils.dart';

class AvaliacaoServico {
  final String id;
  final String agendamentoId;
  final String avaliadorId;
  final String avaliadorNome;
  final String? mensagem;
  final double avaliacao;
  final DateTime criadoEm;

  AvaliacaoServico({
    required this.id,
    required this.agendamentoId,
    required this.avaliadorId,
    required this.avaliadorNome,
    this.mensagem,
    required this.avaliacao,
    required this.criadoEm,
  });

  factory AvaliacaoServico.fromJson(Map<String, dynamic> json) {
    return AvaliacaoServico(
      id: JsonUtils.requireString(json, 'id'),
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
      avaliadorId: JsonUtils.requireString(json, 'avaliador_id'),
      avaliadorNome: JsonUtils.requireString(json, 'avaliador_nome'),
      mensagem: JsonUtils.optionalString(json, 'mensagem'),
      avaliacao: JsonUtils.requireDouble(json, 'avaliacao'),
      criadoEm: JsonUtils.requireDateTime(json, 'criado_em'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'agendamento_id': agendamentoId,
    'avaliador_id': avaliadorId,
    'avaliador_nome': avaliadorNome,
    'mensagem': mensagem,
    'avaliacao': avaliacao,
    'criado_em': criadoEm.toIso8601String(),
  };
}
