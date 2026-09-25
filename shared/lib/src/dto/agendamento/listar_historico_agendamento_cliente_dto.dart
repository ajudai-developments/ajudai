import 'package:shared/shared.dart';

class ListarHistoricoAgendamentoClienteRequestDto implements WsMessage {
  ListarHistoricoAgendamentoClienteRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.listarAgendamentosHistoricoCliente;

  factory ListarHistoricoAgendamentoClienteRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarHistoricoAgendamentoClienteRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class ListarHistoricoAgendamentoClienteResponseDto implements WsMessage {
  final List<AgendamentoDetalhadoCliente> agendamentos;
  ListarHistoricoAgendamentoClienteResponseDto({required this.agendamentos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarAgendamentosHistoricoClienteOk;

  factory ListarHistoricoAgendamentoClienteResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarHistoricoAgendamentoClienteResponseDto(
      agendamentos: (json['agendamentos'] as List)
          .map((a) => AgendamentoDetalhadoCliente.fromJson(a))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamentos': agendamentos.map((a) => a.toJson()).toList(),
  };
}
