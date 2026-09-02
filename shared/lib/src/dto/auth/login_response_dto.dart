import 'package:shared/shared.dart';

class LoginResponseDto implements WsMessage {
  final Usuario usuario;

  LoginResponseDto({required this.usuario});

  @override
  TipoMensagem get tipo => TipoMensagem.loginOk;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(usuario: Usuario.fromJson(json));
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, 'usuario': usuario};
}
