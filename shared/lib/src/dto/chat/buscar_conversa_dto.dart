// request
import 'package:shared/shared.dart';

class BuscarConversaRequestDto implements WsMessage {
  final String conversaId;

  BuscarConversaRequestDto({required this.conversaId});

  @override
  TipoMensagem get tipo => TipoMensagem.buscarConversa;

  factory BuscarConversaRequestDto.fromJson(Map<String, dynamic> json) {
    return BuscarConversaRequestDto(
      conversaId: JsonUtils.requireString(json, 'conversa_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'conversa_id': conversaId,
  };
}

// response
class BuscarConversaResponseDto implements WsMessage {
  final ConversaResumo conversa;

  BuscarConversaResponseDto({required this.conversa});

  @override
  TipoMensagem get tipo => TipoMensagem.buscarConversaOk;

  factory BuscarConversaResponseDto.fromJson(Map<String, dynamic> json) {
    return BuscarConversaResponseDto(
      conversa: ConversaResumo.fromMap(
        json['conversa'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'conversa': conversa.toJson(),
  };
}
