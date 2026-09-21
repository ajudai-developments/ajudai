import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/usuario_basico.dart';

class ConversaResumo {
  final String id;
  final UsuarioBasico outroUsuario;
  final String? ultimaMensagemTexto;
  final DateTime? ultimaMensagemEm;
  final bool emAgendamentoAtivo;

  ConversaResumo({
    required this.id,
    required this.outroUsuario,
    this.ultimaMensagemTexto,
    this.ultimaMensagemEm,
    required this.emAgendamentoAtivo,
  });

  factory ConversaResumo.fromMap(Map<String, dynamic> map) {
    return ConversaResumo(
      id: JsonUtils.requireString(map, 'conversa_id'),
      outroUsuario: UsuarioBasico(
        id: JsonUtils.requireString(map, 'outro_id'),
        nome: JsonUtils.requireString(map, 'outro_nome'),
        verificado: map['outro_verificado'] as bool,
        statusUsuario: map['outro_status_usuario'] as bool,
        criadoEm: JsonUtils.requireDateTime(map, 'outro_criado_em'),
      ),
      ultimaMensagemTexto: JsonUtils.optionalString(
        map,
        'ultima_mensagem_texto',
      ),
      ultimaMensagemEm: JsonUtils.optionalDateTime(map, 'ultima_mensagem_em'),
      emAgendamentoAtivo: map['em_agendamento_ativo'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'outro_usuario': outroUsuario.toJson(),
    'ultima_mensagem_texto': ultimaMensagemTexto,
    'ultima_mensagem_em': ultimaMensagemEm?.toIso8601String(),
    'em_agendamento_ativo': emAgendamentoAtivo,
  };
}
