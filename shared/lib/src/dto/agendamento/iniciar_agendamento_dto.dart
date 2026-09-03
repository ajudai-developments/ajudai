import 'package:shared/shared.dart';

class IniciarAgendamentoRequestDto implements WsMessage {
  final String agendamentoId;
  IniciarAgendamentoRequestDto({required this.agendamentoId});

  @override
  TipoMensagem get tipo => TipoMensagem.iniciarAgendamento;

  factory IniciarAgendamentoRequestDto.fromJson(Map<String, dynamic> json) {
    return IniciarAgendamentoRequestDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
  };
}

class IniciarAgendamentoResponseDto implements WsMessage {
  final Agendamento agendamento;
  IniciarAgendamentoResponseDto({required this.agendamento});

  @override
  TipoMensagem get tipo => TipoMensagem.iniciarAgendamentoOk;

  factory IniciarAgendamentoResponseDto.fromJson(Map<String, dynamic> json) {
    return IniciarAgendamentoResponseDto(
      agendamento: Agendamento.fromJson(json['agendamento']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento': agendamento.toJson(),
  };
}
