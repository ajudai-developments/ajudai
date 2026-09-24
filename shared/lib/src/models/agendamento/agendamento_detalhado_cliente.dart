import 'package:shared/shared.dart';

class AgendamentoDetalhadoCliente {
  final Agendamento agendamento;
  final String prestadorNome;
  final String? prestadorAvatarUrl;
  final bool prestadorVerificado;

  AgendamentoDetalhadoCliente({
    required this.agendamento,
    required this.prestadorNome,
    required this.prestadorAvatarUrl,
    required this.prestadorVerificado,
  });

  factory AgendamentoDetalhadoCliente.fromJson(Map<String, dynamic> json) {
    return AgendamentoDetalhadoCliente(
      agendamento: Agendamento.fromJson(json),
      prestadorNome: JsonUtils.requireString(json, 'prestador_nome'),
      prestadorAvatarUrl: JsonUtils.optionalString(
        json,
        'prestador_avatar_url',
      ),
      prestadorVerificado: json['prestador_verificado'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    ...agendamento.toJson(),
    'prestador_nome': prestadorNome,
    'prestador_verificado': prestadorVerificado,
    'prestador_avatar_url': prestadorAvatarUrl,
  };
}
