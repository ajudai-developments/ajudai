import 'package:shared/shared.dart';

class ListarHistoricoAgendamentoPrestadorRequestDto implements WsMessage {
  ListarHistoricoAgendamentoPrestadorRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.listarAgendamentosHistoricoPrestador;

  factory ListarHistoricoAgendamentoPrestadorRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarHistoricoAgendamentoPrestadorRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class ListarHistoricoAgendamentoPrestadorResponseDto implements WsMessage {
  final List<AgendamentoDetalhadoPrestador> agendamentos;
  ListarHistoricoAgendamentoPrestadorResponseDto({required this.agendamentos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarAgendamentosHistoricoPrestadorOk;

  factory ListarHistoricoAgendamentoPrestadorResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarHistoricoAgendamentoPrestadorResponseDto(
      agendamentos: (json['agendamentos'] as List)
          .map((a) => AgendamentoDetalhadoPrestador.fromJson(a))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamentos': agendamentos.map((a) => a.toJson()).toList(),
  };
}
