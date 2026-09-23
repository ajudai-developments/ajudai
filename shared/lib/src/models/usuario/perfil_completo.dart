import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/conquista/conquista_usuario.dart';

class PerfilCompleto {
  final double? mediaAvaliacao;
  final int totalAvaliacoes;
  final List<ConquistaUsuario> conquistas;

  PerfilCompleto({
    required this.mediaAvaliacao,
    required this.totalAvaliacoes,
    required this.conquistas,
  });

  factory PerfilCompleto.fromJson(Map<String, dynamic> json) {
    final listaConquistas = JsonUtils.requireListaDeMapas(json, 'conquistas');
    return PerfilCompleto(
      mediaAvaliacao: JsonUtils.optionalDouble(json, 'media_avaliacao'),
      totalAvaliacoes: JsonUtils.requireInt(json, 'total_avaliacoes'),
      conquistas: listaConquistas.map(ConquistaUsuario.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'media_avaliacao': mediaAvaliacao,
    'total_avaliacoes': totalAvaliacoes,
    'conquistas': conquistas.map((c) => c.toJson()).toList(),
  };
}
