import 'package:shared/src/dto/tipo_mensagem.dart';

import '../ws_message.dart';
import '../../models/usuario.dart';

class AtualizarPerfilResponseDto implements WsMessage {
  final Usuario usuario;

  AtualizarPerfilResponseDto({required this.usuario});

  @override
  TipoMensagem get tipo => TipoMensagem.atualizarPerfilOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'usuario': usuario.toJson(),
  };
}
