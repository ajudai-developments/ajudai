import 'package:shared/shared.dart';

class ResponderAgendamentoRequestDto implements WsMessage {
  final String agendamentoId;
  final bool aceitar;

  ResponderAgendamentoRequestDto({
    required this.agendamentoId,
    required this.aceitar,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.responderAgendamento;

  factory ResponderAgendamentoRequestDto.fromJson(Map<String, dynamic> json) {
    return ResponderAgendamentoRequestDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
      aceitar: JsonUtils.requireBool(json, 'aceitar'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
    'aceitar': aceitar,
  };
}

class ResponderAgendamentoResponseDto implements WsMessage {
  final Agendamento agendamento;
  ResponderAgendamentoResponseDto({required this.agendamento});

  @override
  TipoMensagem get tipo => TipoMensagem.responderAgendamentoOk;

  factory ResponderAgendamentoResponseDto.fromJson(Map<String, dynamic> json) {
    return ResponderAgendamentoResponseDto(
      agendamento: Agendamento.fromJson(json['agendamento']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento': agendamento.toJson(),
  };
}
