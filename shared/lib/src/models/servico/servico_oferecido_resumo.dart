import 'package:shared/src/dto/json_utils.dart';

class ServicoOferecidoResumo {
  final String servicoOferecidoId;
  final String servicoNome;
  final String categoriaNome;
  final String descricao;
  final double valor;

  ServicoOferecidoResumo({
    required this.servicoOferecidoId,
    required this.servicoNome,
    required this.categoriaNome,
    required this.descricao,
    required this.valor,
  });

  factory ServicoOferecidoResumo.fromJson(Map<String, dynamic> json) {
    return ServicoOferecidoResumo(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
      servicoNome: JsonUtils.requireString(json, 'servico_nome'),
      categoriaNome: JsonUtils.requireString(json, 'categoria_nome'),
      descricao: JsonUtils.requireString(json, 'descricao'),
      valor: JsonUtils.requireDouble(json, 'valor'),
    );
  }

  Map<String, dynamic> toJson() => {
    'servico_oferecido_id': servicoOferecidoId,
    'servico_nome': servicoNome,
    'categoria_nome': categoriaNome,
    'descricao': descricao,
    'valor': valor,
  };
}
