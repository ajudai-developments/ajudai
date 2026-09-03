import 'package:shared/shared.dart';

class ListarMeusAgendamentosRequestDto implements WsMessage {
  final List<String>? status;
  ListarMeusAgendamentosRequestDto({this.status});

  @override
  TipoMensagem get tipo => TipoMensagem.listarMeusAgendamentos;

  factory ListarMeusAgendamentosRequestDto.fromJson(Map<String, dynamic> json) {
    final raw = json['status'];
    return ListarMeusAgendamentosRequestDto(
      status: raw == null ? null : List<String>.from(raw as List),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, 'status': status};
}

class ListarAgendamentosRecebidosRequestDto implements WsMessage {
  final List<String>? status;
  ListarAgendamentosRecebidosRequestDto({this.status});

  @override
  TipoMensagem get tipo => TipoMensagem.listarAgendamentosRecebidos;

  factory ListarAgendamentosRecebidosRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json['status'];
    return ListarAgendamentosRecebidosRequestDto(
      status: raw == null ? null : List<String>.from(raw as List),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, 'status': status};
}

class ListarAgendamentosResponseDto implements WsMessage {
  final List<Agendamento> agendamentos;
  @override
  final TipoMensagem tipo;

  ListarAgendamentosResponseDto({
    required this.agendamentos,
    required this.tipo,
  });

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamentos': agendamentos.map((a) => a.toJson()).toList(),
  };
}
