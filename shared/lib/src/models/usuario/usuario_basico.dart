import 'package:shared/shared.dart';

class UsuarioBasico {
  final String id;
  final String nome;
  final bool verificado;
  final bool statusUsuario;
  final String? avatarUrl;
  final DateTime criadoEm;

  UsuarioBasico({
    required this.id,
    required this.nome,
    required this.verificado,
    required this.statusUsuario,
    this.avatarUrl,
    required this.criadoEm,
  });

  factory UsuarioBasico.fromJson(Map<String, dynamic> json) {
    return UsuarioBasico(
      id: JsonUtils.requireString(json, 'id'),
      nome: JsonUtils.requireString(json, 'nome'),
      verificado: json['verificado'] as bool,
      statusUsuario: json['status_usuario'] as bool,
      avatarUrl: JsonUtils.optionalString(json, 'avatar_url'),
      criadoEm: JsonUtils.requireDateTime(json, 'criado_em'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'verificado': verificado,
    'status_usuario': statusUsuario,
    'avatar_url': avatarUrl,
    'criado_em': criadoEm.toIso8601String(),
  };
}
