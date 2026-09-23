import 'package:shared/shared.dart';

class CriarConversaRequestDto implements WsMessage {
  final String prestadorId;

  CriarConversaRequestDto({required this.prestadorId});

  factory CriarConversaRequestDto.fromJson(Map<String, dynamic> json) {
    return CriarConversaRequestDto(
      prestadorId: JsonUtils.requireString(json, 'prestador_id'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.criarConversa;

  @override
  Map<String, dynamic> toJson() {
    return {'tipo': tipo.valor, 'prestador_id': prestadorId};
  }
}

class CriarConversaResponseDto implements WsMessage {
  final String conversaId;

  CriarConversaResponseDto({required this.conversaId});

  factory CriarConversaResponseDto.fromJson(Map<String, dynamic> json) {
    return CriarConversaResponseDto(
      conversaId: JsonUtils.requireString(json, 'conversa_id'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.criarConversaOk;

  @override
  Map<String, dynamic> toJson() {
    return {'tipo': tipo.valor, 'conversa_id': conversaId};
  }
}
