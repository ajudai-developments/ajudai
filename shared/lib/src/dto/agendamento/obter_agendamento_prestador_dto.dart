import 'package:shared/shared.dart';

class ObterAgendamentoRequestPrestadorDto implements WsMessage {
  final String agendamentoId;
  ObterAgendamentoRequestPrestadorDto({required this.agendamentoId});

  @override
  TipoMensagem get tipo => TipoMensagem.obterAgendamentoPrestador;

  factory ObterAgendamentoRequestPrestadorDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ObterAgendamentoRequestPrestadorDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
  };
}

class ObterAgendamentoPrestadorResponseDto implements WsMessage {
  final AgendamentoDetalhadoPrestador agendamento;
  ObterAgendamentoPrestadorResponseDto({required this.agendamento});

  @override
  TipoMensagem get tipo => TipoMensagem.obterAgendamentoPrestadorOk;

  factory ObterAgendamentoPrestadorResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ObterAgendamentoPrestadorResponseDto(
      agendamento: AgendamentoDetalhadoPrestador.fromJson(json['agendamento']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento': agendamento.toJson(),
  };
}
