import 'package:shared/shared.dart';

class ConcluirAgendamentoRequestDto implements WsMessage {
  final String agendamentoId;
  ConcluirAgendamentoRequestDto({required this.agendamentoId});

  @override
  TipoMensagem get tipo => TipoMensagem.concluirAgendamento;

  factory ConcluirAgendamentoRequestDto.fromJson(Map<String, dynamic> json) {
    return ConcluirAgendamentoRequestDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
  };
}

class ConcluirAgendamentoResponseDto implements WsMessage {
  final Agendamento agendamento;
  ConcluirAgendamentoResponseDto({required this.agendamento});

  @override
  TipoMensagem get tipo => TipoMensagem.concluirAgendamentoOk;

  factory ConcluirAgendamentoResponseDto.fromJson(Map<String, dynamic> json) {
    return ConcluirAgendamentoResponseDto(
      agendamento: Agendamento.fromJson(json['agendamento']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento': agendamento.toJson(),
  };
}
