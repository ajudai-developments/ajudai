import 'package:shared/shared.dart';

class CriarConversaRequestDto implements WsMessage {
  final String idPrestador;

  CriarConversaRequestDto({required this.idPrestador});

  factory CriarConversaRequestDto.fromJson(Map<String, dynamic> json) {
    return CriarConversaRequestDto(
      idPrestador: JsonUtils.requireString(json, 'id_prestador'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.criarConversa;

  @override
  Map<String, dynamic> toJson() {
    return {'id_prestador': idPrestador};
  }
}

class CriarConversaResponseDto implements WsMessage {
  final String idConversa;

  CriarConversaResponseDto({required this.idConversa});

  factory CriarConversaResponseDto.fromJson(Map<String, dynamic> json) {
    return CriarConversaResponseDto(
      idConversa: JsonUtils.requireString(json, 'id_conversa'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.criarConversaOk;

  @override
  Map<String, dynamic> toJson() {
    return {'id_conversa': idConversa};
  }
}
