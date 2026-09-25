import 'package:shared/shared.dart';

class AgendamentoDetalhadoCliente {
  final Agendamento agendamento;
  final String prestadorNome;
  final String? prestadorAvatarUrl;
  final bool prestadorVerificado;
  final bool avaliacaoAgendamentoFeita;
  final bool avaliacaoUsuarioFeita;

  AgendamentoDetalhadoCliente({
    required this.agendamento,
    required this.prestadorNome,
    required this.prestadorAvatarUrl,
    required this.prestadorVerificado,
    this.avaliacaoAgendamentoFeita = false,
    this.avaliacaoUsuarioFeita = false,
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
      avaliacaoAgendamentoFeita: JsonUtils.optionalBool(
        json,
        'avaliacao_agendamento_feita',
      ),
      avaliacaoUsuarioFeita: JsonUtils.optionalBool(
        json,
        'avaliacao_usuario_feita',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    ...agendamento.toJson(),
    'prestador_nome': prestadorNome,
    'prestador_avatar_url': prestadorAvatarUrl,
    'prestador_verificado': prestadorVerificado,
    'avaliacao_agendamento_feita': avaliacaoAgendamentoFeita,
    'avaliacao_usuario_feita': avaliacaoUsuarioFeita,
  };
}
