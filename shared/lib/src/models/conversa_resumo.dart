import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/usuario_basico.dart';

class ConversaResumo {
  final String conversaId;
  final UsuarioBasico outroUsuario;
  final String? ultimaMensagemTexto;
  final DateTime? ultimaMensagemEm;
  final bool? ultimaMensagemDeMim;

  ConversaResumo({
    required this.conversaId,
    required this.outroUsuario,
    this.ultimaMensagemTexto,
    this.ultimaMensagemEm,
    this.ultimaMensagemDeMim,
  });

  factory ConversaResumo.fromMap(Map<String, dynamic> map) {
    return ConversaResumo(
      conversaId: JsonUtils.requireString(map, 'conversa_id'),
      outroUsuario: UsuarioBasico.fromJson(
        map["outro_usuario"] as Map<String, dynamic>,
      ),
      ultimaMensagemTexto: JsonUtils.optionalString(
        map,
        'ultima_mensagem_texto',
      ),
      ultimaMensagemEm: JsonUtils.optionalDateTime(map, 'ultima_mensagem_em'),
      ultimaMensagemDeMim: map['ultima_mensagem_de_mim'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'conversa_id': conversaId,
    'outro_usuario': outroUsuario.toJson(),
    'ultima_mensagem_texto': ultimaMensagemTexto,
    'ultima_mensagem_em': ultimaMensagemEm?.toIso8601String(),
    'ultima_mensagem_de_mim': ultimaMensagemDeMim,
  };
}
