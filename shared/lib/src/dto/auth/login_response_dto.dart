import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class LoginResponseDto implements WsMessage {
  final String userId;

  LoginResponseDto({required this.userId});

  @override
  TipoMensagem get tipo => TipoMensagem.loginOk;

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, 'userId': userId};
}
