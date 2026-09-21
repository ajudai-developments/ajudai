import 'package:shared/shared.dart';

class AtivarServicoOferecidoRequestDto implements WsMessage {
  final String servicoOferecidoId;

  const AtivarServicoOferecidoRequestDto({required this.servicoOferecidoId});

  factory AtivarServicoOferecidoRequestDto.fromJson(Map<String, dynamic> json) {
    return AtivarServicoOferecidoRequestDto(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.ativarServicoOferecido;

  @override
  Map<String, dynamic> toJson() => {
    "tipo": tipo.valor,
    "servico_oferecido_id": servicoOferecidoId,
  };
}

class AtivarServicoOferecidoResponseDto implements WsMessage {
  final String mensagem;

  const AtivarServicoOferecidoResponseDto({required this.mensagem});

  factory AtivarServicoOferecidoResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return AtivarServicoOferecidoResponseDto(
      mensagem: JsonUtils.requireString(json, 'mensagem'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.ativarServicoOferecidoOk;

  @override
  Map<String, dynamic> toJson() => {"tipo": tipo.valor, "mensagem": mensagem};
}
