import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/enums/tipo_denuncia.dart';
import 'package:shared/src/models/arquivos/arquivo_anexado.dart';

class Denuncia {
  final String id;
  final String usuarioId;
  final String usuarioNome;
  final String denunciadorId;
  final TipoDenuncia tipo;
  final String descricao;
  final DateTime denunciadoEm;
  final List<ArquivoAnexado> arquivos;

  Denuncia({
    required this.id,
    required this.usuarioId,
    required this.usuarioNome,
    required this.denunciadorId,
    required this.tipo,
    required this.descricao,
    required this.denunciadoEm,
    required this.arquivos,
  });

  factory Denuncia.fromJson(Map<String, dynamic> json) {
    final arquivos = JsonUtils.requireListaDeMapas(json, 'arquivos');
    return Denuncia(
      id: JsonUtils.requireString(json, 'id'),
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
      usuarioNome: JsonUtils.requireString(json, 'usuario_nome'),
      denunciadorId: JsonUtils.requireString(json, 'denunciador_id'),
      tipo: TipoDenuncia.fromValor(JsonUtils.requireString(json, 'tipo')),
      descricao: JsonUtils.requireString(json, 'descricao'),
      denunciadoEm: JsonUtils.requireDateTime(json, 'denunciado_em'),
      arquivos: arquivos.map(ArquivoAnexado.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'usuario_nome': usuarioNome,
    'denunciador_id': denunciadorId,
    'tipo': tipo.valor,
    'descricao': descricao,
    'denunciado_em': denunciadoEm.toIso8601String(),
    'arquivos': arquivos.map((a) => a.toJson()).toList(),
  };
}
