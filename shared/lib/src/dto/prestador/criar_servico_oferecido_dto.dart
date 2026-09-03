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
      servicoId: JsonUtils.requireString(json, 'servico_id'),
      descricao: JsonUtils.requireString(json, 'descricao'),
      valor: JsonUtils.requireDouble(json, 'valor'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_id': servicoId,
    'descricao': descricao,
    'valor': valor,
  };
}

class CriarServicoOferecidoResponseDto implements WsMessage {
  final ServicoOferecido servicoOferecido;
  CriarServicoOferecidoResponseDto({required this.servicoOferecido});

  @override
  TipoMensagem get tipo => TipoMensagem.criarServicoOferecidoOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_oferecido': servicoOferecido.toJson(),
  };
}
