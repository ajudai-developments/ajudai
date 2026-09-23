import 'package:shared/shared.dart';

class ServicoOferecido {
  final String id;
  final String servicoId;
  final String usuarioId;
  final String descricao;
  final double valor;

  ServicoOferecido({
    required this.id,
    required this.servicoId,
    required this.usuarioId,
    required this.descricao,
    required this.valor,
  });

  factory ServicoOferecido.fromJson(Map<String, dynamic> json) =>
      ServicoOferecido(
        id: JsonUtils.requireString(json, 'id'),
        servicoId: JsonUtils.requireString(json, 'servico_id'),
        usuarioId: JsonUtils.requireString(json, 'usuario_id'),
        descricao: JsonUtils.requireString(json, 'descricao'),
        valor: JsonUtils.requireDouble(json, 'valor'),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'servico_id': servicoId,
    'usuario_id': usuarioId,
    'descricao': descricao,
    'valor': valor,
  };
}
