import 'package:shared/src/dto/json_utils.dart';

class ServicoRecente {
  final String servicoId;
  final String servicoNome;

  const ServicoRecente({required this.servicoId, required this.servicoNome});

  factory ServicoRecente.fromJson(Map<String, dynamic> json) {
    return ServicoRecente(
      servicoId: JsonUtils.requireString(json, 'servico_id'),
      servicoNome: JsonUtils.requireString(json, 'servico_nome'),
    );
  }

  Map<String, dynamic> toJson() => {
    'servico_id': servicoId,
    'servico_nome': servicoNome,
  };
}
