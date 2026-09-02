import 'package:shared/shared.dart';

/// Usado na listagem de solicitações para o admin: junta a verificação
/// com os dados básicos de quem pediu para virar prestador.
class VerificacaoComUsuario {
  final Verificacao verificacao;
  final String usuarioNome;
  final String usuarioCpf;
  final String? usuarioTelefone;

  VerificacaoComUsuario({
    required this.verificacao,
    required this.usuarioNome,
    required this.usuarioCpf,
    this.usuarioTelefone,
  });

  factory VerificacaoComUsuario.fromJson(Map<String, dynamic> json) {
    return VerificacaoComUsuario(
      verificacao: Verificacao.fromJson(
        json['verificacao'] as Map<String, dynamic>,
      ),
      usuarioNome: JsonUtils.requireString(json, 'usuario_nome'),
      usuarioCpf: JsonUtils.requireString(json, 'usuario_cpf'),
      usuarioTelefone: JsonUtils.optionalString(json, 'usuario_telefone'),
    );
  }

  Map<String, dynamic> toJson() => {
    'verificacao': verificacao.toJson(),
    'usuario_nome': usuarioNome,
    'usuario_cpf': usuarioCpf,
    'usuario_telefone': usuarioTelefone,
  };
}
