import 'package:shared/shared.dart';

class ExcluirServicoOferecidoRequestDto implements WsMessage {
  final String servicoOferecidoId;

  const ExcluirServicoOferecidoRequestDto({required this.servicoOferecidoId});

  factory ExcluirServicoOferecidoRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExcluirServicoOferecidoRequestDto(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.editarServicoOferecido;

  @override
  Map<String, dynamic> toJson() => {
    "tipo": tipo.valor,
    "servico_oferecido_id": servicoOferecidoId,
  };
}

class ExcluirServicoOferecidoResponseDto implements WsMessage {
  final String mensagem;

  const ExcluirServicoOferecidoResponseDto({required this.mensagem});

  factory ExcluirServicoOferecidoResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExcluirServicoOferecidoResponseDto(
      mensagem: JsonUtils.requireString(json, 'mensagem'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.editarServicoOferecidoOk;

  @override
  Map<String, dynamic> toJson() => {
    "tipo": tipo.valor,
    "mensagem": "Servico excluído com sucesso!",
  };
}
