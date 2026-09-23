import 'package:shared/shared.dart';

class AgendamentoDetalhadoPrestador {
  final Agendamento agendamento;
  final String clienteNome;
  final String clienteAvatarUrl;
  final bool clienteStatusUsuario;

  AgendamentoDetalhadoPrestador({
    required this.agendamento,
    required this.clienteNome,
    required this.clienteAvatarUrl,
    required this.clienteStatusUsuario,
  });

  factory AgendamentoDetalhadoPrestador.fromJson(Map<String, dynamic> json) {
    return AgendamentoDetalhadoPrestador(
      agendamento: Agendamento.fromJson(json),
      clienteNome: JsonUtils.requireString(json, 'cliente_nome'),
      clienteAvatarUrl: JsonUtils.requireString(json, 'cliente_avatar_url'),
      clienteStatusUsuario: json['cliente_status_usuario'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    ...agendamento.toJson(),
    'cliente_nome': clienteNome,
    'cliente_avatar_url': clienteAvatarUrl,
    'cliente_status_usuario': clienteStatusUsuario,
  };
}
