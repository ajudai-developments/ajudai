import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/enums/tipo_conquista.dart';

class Conquista {
  final String id;
  final String nome;
  final String descricao;
  final TipoConquista tipo;
  final int? meta;

  Conquista({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.tipo,
    this.meta,
  });

  factory Conquista.fromJson(Map<String, dynamic> json) {
    return Conquista(
      id: JsonUtils.requireString(json, 'id'),
      nome: JsonUtils.requireString(json, 'nome'),
      descricao: JsonUtils.requireString(json, 'descricao'),
      tipo: TipoConquista.fromValor(JsonUtils.requireString(json, 'tipo')),
      meta: JsonUtils.optionalInt(json, 'meta'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'descricao': descricao,
    'tipo': tipo.valor,
    'meta': meta,
  };
}
