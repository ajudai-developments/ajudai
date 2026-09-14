import 'package:shared/shared.dart';

class DesativarServicoOferecidoRequestDto implements WsMessage {
  final String servicoOferecidoId;

  const DesativarServicoOferecidoRequestDto({required this.servicoOferecidoId});

  factory DesativarServicoOferecidoRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return DesativarServicoOferecidoRequestDto(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.desativarServicoOferecido;

  @override
  Map<String, dynamic> toJson() => {
    "tipo": tipo.valor,
    "servico_oferecido_id": servicoOferecidoId,
  };
}

class DesativarServicoOferecidoResponseDto implements WsMessage {
  final String mensagem;

  const DesativarServicoOferecidoResponseDto({required this.mensagem});

  factory DesativarServicoOferecidoResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return DesativarServicoOferecidoResponseDto(
      mensagem: JsonUtils.requireString(json, 'mensagem'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.desativarServicoOferecidoOk;

  @override
  Map<String, dynamic> toJson() => {
    "tipo": tipo.valor,
    "mensagem": "Servico excluído com sucesso!",
  };
}
