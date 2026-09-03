import 'package:shared/shared.dart';

class ObterAgendamentoRequestDto implements WsMessage {
  final String agendamentoId;
  ObterAgendamentoRequestDto({required this.agendamentoId});

  @override
  TipoMensagem get tipo => TipoMensagem.obterAgendamento;

  factory ObterAgendamentoRequestDto.fromJson(Map<String, dynamic> json) {
    return ObterAgendamentoRequestDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
  };
}

class ObterAgendamentoResponseDto implements WsMessage {
  final Agendamento agendamento;
  ObterAgendamentoResponseDto({required this.agendamento});

  @override
  TipoMensagem get tipo => TipoMensagem.obterAgendamentoOk;

  factory ObterAgendamentoResponseDto.fromJson(Map<String, dynamic> json) {
    return ObterAgendamentoResponseDto(
      agendamento: Agendamento.fromJson(json['agendamento']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento': agendamento.toJson(),
  };
}
