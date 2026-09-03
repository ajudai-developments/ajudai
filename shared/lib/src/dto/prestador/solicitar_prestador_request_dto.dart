import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class SolicitarPrestadorRequestDto implements WsMessage {
  SolicitarPrestadorRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.solicitarPrestador;

  factory SolicitarPrestadorRequestDto.fromJson(Map<String, dynamic> json) {
    return SolicitarPrestadorRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}
