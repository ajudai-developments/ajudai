import 'package:shared/shared.dart';

class AtualizarAvatarRequestDto implements WsMessage {
  final String imagemBase64;
  final String extensao;

  AtualizarAvatarRequestDto({
    required this.imagemBase64,
    required this.extensao,
  });

  factory AtualizarAvatarRequestDto.fromJson(Map<String, dynamic> json) {
    return AtualizarAvatarRequestDto(
      imagemBase64: JsonUtils.requireString(json, 'imagem_base64'),
      extensao: JsonUtils.requireString(json, 'extensao'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.atualizarAvatar;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'imagem_base64': imagemBase64,
    'extensao': extensao,
  };
}

class AtualizarAvatarResponseDto implements WsMessage {
  final String avatarUrl;

  AtualizarAvatarResponseDto({required this.avatarUrl});

  factory AtualizarAvatarResponseDto.fromJson(Map<String, dynamic> json) {
    return AtualizarAvatarResponseDto(
      avatarUrl: JsonUtils.requireString(json, 'avatar_url'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.atualizarAvatarOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'avatar_url': avatarUrl,
  };
}
