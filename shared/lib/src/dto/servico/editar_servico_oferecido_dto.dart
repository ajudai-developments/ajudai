import 'package:shared/shared.dart';

class EditarServicoOferecidoRequestDto implements WsMessage {
  final String servicoOferecidoId;
  final String? descricao;
  final double? valor;

  const EditarServicoOferecidoRequestDto({
    required this.servicoOferecidoId,
    required this.descricao,
    required this.valor,
  });

  factory EditarServicoOferecidoRequestDto.fromJson(Map<String, dynamic> json) {
    return EditarServicoOferecidoRequestDto(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
      descricao: JsonUtils.optionalString(json, 'descricao'),
      valor: JsonUtils.optionalDouble(json, 'valor'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.editarServicoOferecido;

  @override
  Map<String, dynamic> toJson() => {
    "tipo": tipo.valor,
    "servico_oferecido_id": servicoOferecidoId,
    "descricao": descricao,
    "valor": valor,
  };
}

class EditarServicoOferecidoResponseDto implements WsMessage {
  final ServicoOferecido servico;

  const EditarServicoOferecidoResponseDto({required this.servico});

  factory EditarServicoOferecidoResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return EditarServicoOferecidoResponseDto(
      servico: ServicoOferecido.fromJson(json["servico"]),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.editarServicoOferecidoOk;

  @override
  Map<String, dynamic> toJson() => {
    "tipo": tipo.valor,
    "servico": servico.toJson(),
  };
}
