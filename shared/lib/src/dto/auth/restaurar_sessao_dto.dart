import 'package:shared/shared.dart';

class RestaurarSessaoRequestDto implements WsMessage {
  final String refreshToken;

  RestaurarSessaoRequestDto({required this.refreshToken});

  @override
  TipoMensagem get tipo => TipoMensagem.restaurarSessao;

  factory RestaurarSessaoRequestDto.fromJson(Map<String, dynamic> json) {
    return RestaurarSessaoRequestDto(
      refreshToken: JsonUtils.requireString(json, 'refresh_token'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'refresh_token': refreshToken,
  };
}

class RestaurarSessaoResponseDto implements WsMessage {
  final Usuario usuario;
  final String refreshToken;

  RestaurarSessaoResponseDto({
    required this.usuario,
    required this.refreshToken,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.restaurarSessaoOk;

  factory RestaurarSessaoResponseDto.fromJson(Map<String, dynamic> json) {
    return RestaurarSessaoResponseDto(
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
