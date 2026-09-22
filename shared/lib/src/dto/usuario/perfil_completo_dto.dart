import 'package:shared/shared.dart';

class PerfilCompletoRequestDto implements WsMessage {
  PerfilCompletoRequestDto();

  factory PerfilCompletoRequestDto.fromJson(Map<String, dynamic> json) =>
      PerfilCompletoRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.obterPerfilCompleto;

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class PerfilCompletoResponseDto implements WsMessage {
  final PerfilCompleto perfil;

  PerfilCompletoResponseDto({required this.perfil});

  factory PerfilCompletoResponseDto.fromJson(Map<String, dynamic> json) {
    return PerfilCompletoResponseDto(perfil: PerfilCompleto.fromJson(json));
  }

  @override
  TipoMensagem get tipo => TipoMensagem.obterPerfilCompletoOk;

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, ...perfil.toJson()};
}
