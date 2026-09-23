import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/usuario_basico.dart';

class ConversaResumo {
  final String id;
  final UsuarioBasico outroUsuario;
  final String? ultimaMensagemTexto;
  final DateTime? ultimaMensagemEm;
  final bool? ultimaMensagemDeMim;
  final bool emAgendamentoAtivo;

  ConversaResumo({
    required this.id,
    required this.outroUsuario,
    this.ultimaMensagemTexto,
    this.ultimaMensagemEm,
    this.ultimaMensagemDeMim,
    required this.emAgendamentoAtivo,
  });

  factory ConversaResumo.fromMap(Map<String, dynamic> map) {
    return ConversaResumo(
      id: JsonUtils.requireString(map, 'id'),
      outroUsuario: UsuarioBasico.fromJson(
        map["outro_usuario"] as Map<String, dynamic>,
      ),
      ultimaMensagemTexto: JsonUtils.optionalString(
        map,
        'ultima_mensagem_texto',
      ),
      ultimaMensagemEm: JsonUtils.optionalDateTime(map, 'ultima_mensagem_em'),
      ultimaMensagemDeMim: map['ultima_mensagem_de_mim'] as bool?,
      emAgendamentoAtivo: map['em_agendamento_ativo'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'outro_usuario': outroUsuario.toJson(),
    'ultima_mensagem_texto': ultimaMensagemTexto,
    'ultima_mensagem_em': ultimaMensagemEm?.toIso8601String(),
    'ultima_mensagem_de_mim': ultimaMensagemDeMim,
    'em_agendamento_ativo': emAgendamentoAtivo,
  };
}
