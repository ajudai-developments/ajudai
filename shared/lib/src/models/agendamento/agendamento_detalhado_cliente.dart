import 'package:shared/shared.dart';

class AgendamentoDetalhadoCliente {
  final Agendamento agendamento;
  final String prestadorNome;
  final String prestadorAvatarUrl;
  final bool prestadorVerificado;
  final bool comoCliente;

  AgendamentoDetalhadoCliente({
    required this.agendamento,
    required this.prestadorNome,
    required this.prestadorAvatarUrl,
    required this.prestadorVerificado,
    this.comoCliente = true,
  });

  factory AgendamentoDetalhadoCliente.fromJson(Map<String, dynamic> json) {
    return AgendamentoDetalhadoCliente(
      agendamento: Agendamento.fromJson(json),
      prestadorNome: JsonUtils.requireString(json, 'prestador_nome'),
      prestadorAvatarUrl: JsonUtils.requireString(json, 'prestador_avatar_url'),
      prestadorVerificado: json['prestador_verificado'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    ...agendamento.toJson(),
    'prestador_nome': prestadorNome,
    'prestador_verificado': prestadorVerificado,
    'prestador_avatar_url': prestadorAvatarUrl,
    'como_cliente': comoCliente,
  };
}
