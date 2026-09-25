import 'package:shared/shared.dart';

class BuscarAgendamentoProximoPrestadorRequestDto implements WsMessage {
  BuscarAgendamentoProximoPrestadorRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.buscarAgendamentoProximoPrestador;

  factory BuscarAgendamentoProximoPrestadorRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return BuscarAgendamentoProximoPrestadorRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class BuscarAgendamentoProximoPrestadorResponseDto implements WsMessage {
  final AgendamentoDetalhadoPrestador? agendamento;
  BuscarAgendamentoProximoPrestadorResponseDto({required this.agendamento});

  @override
  TipoMensagem get tipo => TipoMensagem.buscarAgendamentoProximoPrestadorOk;

  factory BuscarAgendamentoProximoPrestadorResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return BuscarAgendamentoProximoPrestadorResponseDto(
      agendamento: json['agendamento'] == null
          ? null
          : AgendamentoDetalhadoPrestador.fromJson(
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
