import 'package:shared/shared.dart';

class ListarMeusAgendamentosRequestDto implements WsMessage {
  ListarMeusAgendamentosRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.listarMeusAgendamentos;

  factory ListarMeusAgendamentosRequestDto.fromJson(Map<String, dynamic> json) {
    return ListarMeusAgendamentosRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class ListarAgendamentosRecebidosRequestDto implements WsMessage {
  ListarAgendamentosRecebidosRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.listarAgendamentosRecebidos;

  factory ListarAgendamentosRecebidosRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarAgendamentosRecebidosRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class ListarAgendamentosResponseDto implements WsMessage {
  final List<Agendamento> agendamentos;
  @override
  final TipoMensagem tipo;

  ListarAgendamentosResponseDto({
    required this.agendamentos,
    required this.tipo,
  });

  factory ListarAgendamentosResponseDto.fromJson(Map<String, dynamic> json) {
    final lista = JsonUtils.requireListaDeMapas(json, 'agendamentos');
    return ListarAgendamentosResponseDto(
      agendamentos: lista.map(Agendamento.fromJson).toList(),
      tipo: TipoMensagem.fromValor(json['tipo'] as String?)!,
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamentos': agendamentos.map((a) => a.toJson()).toList(),
  };
}
