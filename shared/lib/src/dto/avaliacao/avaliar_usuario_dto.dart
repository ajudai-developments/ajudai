// shared/lib/src/dto/avaliacao/avaliar_usuario_dto.dart
import '../json_utils.dart';
import '../tipo_mensagem.dart';
import '../ws_message.dart';

class AvaliarUsuarioRequestDto implements WsMessage {
  final String agendamentoId;
  final double? avaliacao;
  final bool pulado;
  final String? descricao;
  final String? mensagem;

  AvaliarUsuarioRequestDto({
    required this.agendamentoId,
    this.avaliacao,
    this.pulado = false,
    this.descricao,
    this.mensagem,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.avaliarUsuario;

  factory AvaliarUsuarioRequestDto.fromJson(Map<String, dynamic> json) {
    return AvaliarUsuarioRequestDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
      avaliacao: JsonUtils.optionalDouble(json, 'avaliacao'),
      pulado: JsonUtils.optionalBool(json, 'pulado'),
      descricao: JsonUtils.optionalString(json, 'descricao'),
      mensagem: JsonUtils.optionalString(json, 'mensagem'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
    'avaliacao': avaliacao,
    'pulado': pulado,
    'descricao': descricao,
    'mensagem': mensagem,
  };
}

class AvaliarUsuarioResponseDto implements WsMessage {
  @override
  TipoMensagem get tipo => TipoMensagem.avaliarUsuarioOk;

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}
