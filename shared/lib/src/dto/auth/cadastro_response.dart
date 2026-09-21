import 'package:shared/shared.dart';

class CadastroResponseDto implements WsMessage {
  final Usuario usuario;
  final String refreshToken;

  CadastroResponseDto({required this.usuario, required this.refreshToken});

  @override
  TipoMensagem get tipo => TipoMensagem.cadastroOk;

  factory CadastroResponseDto.fromJson(Map<String, dynamic> json) {
    return CadastroResponseDto(
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
