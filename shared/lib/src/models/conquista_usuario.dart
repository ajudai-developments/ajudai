import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/conquista.dart';

/// Um "selo" que o prestador já conquistou, para exibir no perfil dele.
class ConquistaUsuario {
  final String id;
  final String usuarioId;
  final Conquista conquista;
  final DateTime dataConquista;

  ConquistaUsuario({
    required this.id,
    required this.usuarioId,
    required this.conquista,
    required this.dataConquista,
  });

  factory ConquistaUsuario.fromJson(Map<String, dynamic> json) {
    return ConquistaUsuario(
      id: JsonUtils.requireString(json, 'id'),
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
      conquista: Conquista.fromJson(json['conquista'] as Map<String, dynamic>),
      dataConquista: JsonUtils.requireDateTime(json, 'data_conquista'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'conquista': conquista.toJson(),
    'data_conquista': dataConquista.toIso8601String(),
  };
}
