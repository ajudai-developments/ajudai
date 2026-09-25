import 'package:shared/src/dto/json_utils.dart';

class AvaliacaoResumo {
  final String id;
  final double avaliacao;
  final String? mensagem;
  final String? descricao;
  final DateTime criadoEm;

  AvaliacaoResumo({
    required this.id,
    required this.avaliacao,
    this.mensagem,
    this.descricao,
    required this.criadoEm,
  });

  factory AvaliacaoResumo.fromJson(Map<String, dynamic> json) {
    return AvaliacaoResumo(
      id: JsonUtils.requireString(json, 'id'),
      avaliacao: JsonUtils.requireDouble(json, 'avaliacao'),
      mensagem: JsonUtils.optionalString(json, 'mensagem'),
      descricao: JsonUtils.optionalString(json, 'descricao'),
      criadoEm: JsonUtils.requireDateTime(json, 'criado_em'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'avaliacao': avaliacao,
    'mensagem': mensagem,
    'descricao': descricao,
    'criado_em': criadoEm.toIso8601String(),
  };
}
