// requisito_verificacao.dart
import 'package:shared/src/dto/json_utils.dart';

class RequisitoVerificacao {
  final String descricao;
  final bool cumprido;
  // texto de apoio, ex: "4.2 de 4.0 exigido" ou "1 de 1 agendamento concluído"
  final String progresso;

  RequisitoVerificacao({
    required this.descricao,
    required this.cumprido,
    required this.progresso,
  });

  factory RequisitoVerificacao.fromJson(Map<String, dynamic> json) {
    return RequisitoVerificacao(
      descricao: JsonUtils.requireString(json, 'descricao'),
      cumprido: json['cumprido'] as bool,
      progresso: JsonUtils.requireString(json, 'progresso'),
    );
  }

  Map<String, dynamic> toJson() => {
    'descricao': descricao,
    'cumprido': cumprido,
    'progresso': progresso,
  };
}
