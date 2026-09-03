import 'package:shared/shared.dart';

class CancelarAgendamentoRequestDto implements WsMessage {
  final String agendamentoId;
  final String motivo;

  CancelarAgendamentoRequestDto({
    required this.agendamentoId,
    required this.motivo,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.cancelarAgendamento;

  factory CancelarAgendamentoRequestDto.fromJson(Map<String, dynamic> json) {
    return CancelarAgendamentoRequestDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
      motivo: JsonUtils.requireString(json, 'motivo'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
    'motivo': motivo,
  };
}

class CancelarAgendamentoResponseDto implements WsMessage {
  final Agendamento agendamento;
  CancelarAgendamentoResponseDto({required this.agendamento});

  @override
  TipoMensagem get tipo => TipoMensagem.cancelarAgendamentoOk;

  factory CancelarAgendamentoResponseDto.fromJson(Map<String, dynamic> json) {
    return CancelarAgendamentoResponseDto(
      agendamento: Agendamento.fromJson(json['agendamento']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento': agendamento.toJson(),
  };
}
