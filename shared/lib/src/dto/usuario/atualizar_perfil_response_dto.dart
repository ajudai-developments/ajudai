import 'package:shared/src/dto/tipo_mensagem.dart';

import '../ws_message.dart';
import '../../models/usuario.dart';

class AtualizarPerfilResponseDto implements WsMessage {
  final Usuario usuario;

  AtualizarPerfilResponseDto({required this.usuario});

  @override
  TipoMensagem get tipo => TipoMensagem.atualizarPerfilOk;

  factory AtualizarPerfilResponseDto.fromJson(Map<String, dynamic> json) {
  return AtualizarPerfilResponseDto(
    usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
  );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'usuario': usuario.toJson(),
  };
}
