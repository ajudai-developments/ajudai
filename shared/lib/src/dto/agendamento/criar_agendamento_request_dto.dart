import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class CriarAgendamentoRequestDto implements WsMessage {
  final String servicoOferecidoId;
  final String enderecoId;
  final DateTime horaInicio;
  final DateTime horaFim;

  CriarAgendamentoRequestDto({
    required this.servicoOferecidoId,
    required this.enderecoId,
    required this.horaInicio,
    required this.horaFim,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.criarAgendamento;

  factory CriarAgendamentoRequestDto.fromJson(Map<String, dynamic> json) {
    return CriarAgendamentoRequestDto(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
      enderecoId: JsonUtils.requireString(json, 'endereco_id'),

      horaInicio: JsonUtils.requireDateTime(json, 'hora_inicio'),
      horaFim: JsonUtils.requireDateTime(json, 'hora_fim'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_oferecido_id': servicoOferecidoId,
    'endereco_id': enderecoId,

    'hora_inicio': horaInicio.toIso8601String(),
    'hora_fim': horaFim.toIso8601String(),
  };
}
