import 'package:shared/shared.dart';

class ObterAgendamentoRequestClienteDto implements WsMessage {
  final String agendamentoId;
  ObterAgendamentoRequestClienteDto({required this.agendamentoId});

  @override
  TipoMensagem get tipo => TipoMensagem.obterAgendamentoCliente;

  factory ObterAgendamentoRequestClienteDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ObterAgendamentoRequestClienteDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
  };
}

class ObterAgendamentoClienteResponseDto implements WsMessage {
  final AgendamentoDetalhadoCliente agendamento;
  ObterAgendamentoClienteResponseDto({required this.agendamento});

  @override
  TipoMensagem get tipo => TipoMensagem.obterAgendamentoClienteOk;

  factory ObterAgendamentoClienteResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ObterAgendamentoClienteResponseDto(
      agendamento: AgendamentoDetalhadoCliente.fromJson(json['agendamento']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento': agendamento.toJson(),
  };
}
