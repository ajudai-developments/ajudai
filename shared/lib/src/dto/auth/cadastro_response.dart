import 'package:shared/shared.dart';

class CadastroResponseDto implements WsMessage {
  final Usuario usuario;

  CadastroResponseDto({required this.usuario});

  @override
  TipoMensagem get tipo => TipoMensagem.cadastroOk;

  factory CadastroResponseDto.fromJson(Map<String, dynamic> json) {
    return CadastroResponseDto(usuario: Usuario.fromJson(json));
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'usuario': usuario.toJson(),
  };
}
