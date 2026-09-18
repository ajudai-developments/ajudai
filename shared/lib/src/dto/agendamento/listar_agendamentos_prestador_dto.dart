import 'package:shared/shared.dart';

class ListarAgendamentosPrestadorRequestDto implements WsMessage {
  ListarAgendamentosPrestadorRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.listarAgendamentosPrestador;

  factory ListarAgendamentosPrestadorRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarAgendamentosPrestadorRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class ListarAgendamentosPrestadorResponseDto implements WsMessage {
  final List<AgendamentoDetalhadoPrestador> agendamentos;
  ListarAgendamentosPrestadorResponseDto({required this.agendamentos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarAgendamentosPrestadorOk;

  factory ListarAgendamentosPrestadorResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarAgendamentosPrestadorResponseDto(
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
