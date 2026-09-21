import 'package:shared/shared.dart';

class LoginResponseDto implements WsMessage {
  final Usuario usuario;
  final String refreshToken;

  LoginResponseDto({required this.usuario, required this.refreshToken});

  @override
  TipoMensagem get tipo => TipoMensagem.loginOk;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
      refreshToken: JsonUtils.requireString(json, 'refresh_token'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'usuario': usuario.toJson(),
    'refresh_token': refreshToken,
  };
}
