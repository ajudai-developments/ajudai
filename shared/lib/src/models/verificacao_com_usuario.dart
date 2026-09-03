import 'package:shared/shared.dart';

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
    final usuario = json["usuarios"] as Map<String, dynamic>;
    return VerificacaoComUsuario(
      verificacao: Verificacao.fromJson(json),
      usuarioNome: JsonUtils.requireString(usuario, 'nome'),
      usuarioCpf: JsonUtils.requireString(usuario, 'cpf'),
      usuarioTelefone: JsonUtils.optionalString(usuario, 'telefone'),
    );
  }

  Map<String, dynamic> toJson() => {
    'verificacao': verificacao.toJson(),
    'usuario_nome': usuarioNome,
    'usuario_cpf': usuarioCpf,
    'usuario_telefone': usuarioTelefone,
  };
}
