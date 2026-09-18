import 'package:shared/shared.dart';

class ListarAgendamentosClienteRequestDto implements WsMessage {
  ListarAgendamentosClienteRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.listarAgendamentosCliente;

  factory ListarAgendamentosClienteRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarAgendamentosClienteRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class ListarAgendamentosClienteResponseDto implements WsMessage {
  final List<AgendamentoDetalhadoCliente> agendamentos;
  ListarAgendamentosClienteResponseDto({required this.agendamentos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarAgendamentosClienteOk;

  factory ListarAgendamentosClienteResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarAgendamentosClienteResponseDto(
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
