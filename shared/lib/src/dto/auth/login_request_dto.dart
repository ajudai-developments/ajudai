import 'package:shared/shared.dart';

class LoginRequestDto implements WsMessage {
  final String email;
  final String senha;

  LoginRequestDto({required this.email, required this.senha});

  @override
  TipoMensagem get tipo => TipoMensagem.login;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) {
    return LoginRequestDto(
      email: JsonUtils.requireString(json, "email"),
      senha: JsonUtils.requireString(json, "senha"),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "tipo": tipo.valor,
    "email": email,
    "senha": senha,
  };
}
