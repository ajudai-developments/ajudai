import 'package:shared/shared.dart';

class CriarServicoOferecidoRequestDto implements WsMessage {
  final String servicoId;
  final String descricao;
  final double valor;

  CriarServicoOferecidoRequestDto({
    required this.servicoId,
    required this.descricao,
    required this.valor,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.criarServicoOferecido;

  factory CriarServicoOferecidoRequestDto.fromJson(Map<String, dynamic> json) {
    return CriarServicoOferecidoRequestDto(
      servicoId: JsonUtils.requireString(json, 'servicoId'),
      descricao: JsonUtils.requireString(json, 'descricao'),
      valor: (json['valor'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servicoId': servicoId,
    'descricao': descricao,
    'valor': valor,
  };
}
