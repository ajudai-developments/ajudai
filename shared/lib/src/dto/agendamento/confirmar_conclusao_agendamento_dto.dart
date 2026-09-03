import 'package:shared/shared.dart';

class ConfirmarConclusaoAgendamentoRequestDto implements WsMessage {
  final String agendamentoId;
  ConfirmarConclusaoAgendamentoRequestDto({required this.agendamentoId});

  @override
  TipoMensagem get tipo => TipoMensagem.confirmarConclusaoAgendamento;

  factory ConfirmarConclusaoAgendamentoRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConfirmarConclusaoAgendamentoRequestDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
  };
}

class ConfirmarConclusaoAgendamentoResponseDto implements WsMessage {
  final Agendamento agendamento;
  ConfirmarConclusaoAgendamentoResponseDto({required this.agendamento});

  @override
  TipoMensagem get tipo => TipoMensagem.confirmarConclusaoAgendamentoOk;

  factory ConfirmarConclusaoAgendamentoResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConfirmarConclusaoAgendamentoResponseDto(
      agendamento: Agendamento.fromJson(json['agendamento']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento': agendamento.toJson(),
  };
}
