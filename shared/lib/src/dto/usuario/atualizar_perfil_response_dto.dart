import '../ws_message.dart';
import '../../models/usuario.dart';

class AtualizarPerfilResponseDto implements WsMessage {
  final Usuario usuario;

  AtualizarPerfilResponseDto({required this.usuario});

  @override
  String get tipo => 'atualizar_perfil_ok';

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo, 'usuario': usuario.toJson()};
}
