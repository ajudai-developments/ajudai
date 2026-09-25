import 'package:shared/shared.dart';

class BuscarAgendamentoProximoClienteRequestDto implements WsMessage {
  BuscarAgendamentoProximoClienteRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.buscarAgendamentoProximoCliente;

  factory BuscarAgendamentoProximoClienteRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return BuscarAgendamentoProximoClienteRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class BuscarAgendamentoProximoClienteResponseDto implements WsMessage {
  final AgendamentoDetalhadoCliente? agendamento;
  BuscarAgendamentoProximoClienteResponseDto({required this.agendamento});

  @override
  TipoMensagem get tipo => TipoMensagem.buscarAgendamentoProximoClienteOk;

  factory BuscarAgendamentoProximoClienteResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return BuscarAgendamentoProximoClienteResponseDto(
      agendamento: json['agendamento'] == null
          ? null
          : AgendamentoDetalhadoCliente.fromJson(
              json['agendamento'] as Map<String, dynamic>,
            ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento': agendamento?.toJson(),
  };
}
