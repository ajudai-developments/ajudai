import 'package:shared/shared.dart';

class LoginResponseDto implements WsMessage {
  final Usuario usuario;

  LoginResponseDto({required this.usuario});

  @override
  TipoMensagem get tipo => TipoMensagem.loginOk;

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, 'usuario': usuario};
}
