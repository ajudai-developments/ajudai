import 'package:shared/shared.dart';

class AgendamentoDetalhadoPrestador {
  final Agendamento agendamento;
  final String clienteNome;
  final String? clienteAvatarUrl;
  final bool clienteVerificado;
  final bool avaliacaoAgendamentoFeita;
  final bool avaliacaoUsuarioFeita;

  AgendamentoDetalhadoPrestador({
    required this.agendamento,
    required this.clienteNome,
    required this.clienteAvatarUrl,
    required this.clienteVerificado,
    this.avaliacaoAgendamentoFeita = false,
    this.avaliacaoUsuarioFeita = false,
  });

  factory AgendamentoDetalhadoPrestador.fromJson(Map<String, dynamic> json) {
    return AgendamentoDetalhadoPrestador(
      agendamento: Agendamento.fromJson(json),
      clienteNome: JsonUtils.requireString(json, 'cliente_nome'),
      clienteAvatarUrl: JsonUtils.optionalString(json, 'cliente_avatar_url'),
      clienteVerificado: json['cliente_verificado'] as bool,
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
    'cliente_nome': clienteNome,
    'cliente_avatar_url': clienteAvatarUrl,
    'cliente_verificado': clienteVerificado,
    'avaliacao_agendamento_feita': avaliacaoAgendamentoFeita,
    'avaliacao_usuario_feita': avaliacaoUsuarioFeita,
  };
}
