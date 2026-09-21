import 'package:shared/src/dto/json_utils.dart';

class UsuarioBasico {
  final String id;
  final String nome;
  final bool verificado;
  final bool statusUsuario;
  final DateTime criadoEm;

  UsuarioBasico({
    required this.id,
    required this.nome,
    required this.verificado,
    required this.statusUsuario,
    required this.criadoEm,
  });

  factory UsuarioBasico.fromJson(Map<String, dynamic> json) {
    return UsuarioBasico(
      id: JsonUtils.requireString(json, 'id'),
      nome: JsonUtils.requireString(json, 'nome'),
      verificado: json['verificado'] as bool,
      statusUsuario: json['status_usuario'] as bool,
      criadoEm: JsonUtils.requireDateTime(json, 'criado_em'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'verificado': verificado,
    'status_usuario': statusUsuario,
    'criado_em': criadoEm.toIso8601String(),
  };
}
