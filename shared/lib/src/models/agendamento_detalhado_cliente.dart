import 'package:shared/shared.dart';

class AgendamentoDetalhadoCliente {
  final Agendamento agendamento;
  final String prestadorNome;
  final bool prestadorStatusUsuario;

  AgendamentoDetalhadoCliente({
    required this.agendamento,
    required this.prestadorNome,
    required this.prestadorStatusUsuario,
  });

  factory AgendamentoDetalhadoCliente.fromJson(Map<String, dynamic> json) {
    return AgendamentoDetalhadoCliente(
      agendamento: Agendamento.fromJson(json),
      prestadorNome: JsonUtils.requireString(json, 'prestador_nome'),
      prestadorStatusUsuario: json['prestador_status_usuario'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    ...agendamento.toJson(),
    'prestador_nome': prestadorNome,
    'prestador_status_usuario': prestadorStatusUsuario,
  };
}
