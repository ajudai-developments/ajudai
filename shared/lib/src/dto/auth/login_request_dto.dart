import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class LoginRequestDto implements WsMessage {
  final String email;
  final String senha;

  LoginRequestDto({required this.email, required this.senha});

  @override
  TipoMensagem get tipo => TipoMensagem.login;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) {
    return LoginRequestDto(
      email: json["email"] as String,
      senha: json["senha"] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "tipo": tipo.valor,
    "email": email,
    "senha": senha,
  };
}
