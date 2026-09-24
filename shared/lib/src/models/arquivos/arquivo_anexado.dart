import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/enums/tipo_arquivo.dart';

class ArquivoAnexado {
  final String id;
  final String nomeOriginal;
  final TipoArquivo tipo;
  final String mimeType;
  final DateTime criadoEm;

  ArquivoAnexado({
    required this.id,
    required this.nomeOriginal,
    required this.tipo,
    required this.mimeType,
    required this.criadoEm,
  });

  factory ArquivoAnexado.fromJson(Map<String, dynamic> json) {
    return ArquivoAnexado(
      id: JsonUtils.requireString(json, 'id'),
      nomeOriginal: JsonUtils.requireString(json, 'nome_original'),
      tipo: TipoArquivo.fromValor(JsonUtils.requireString(json, 'tipo')),
      mimeType: JsonUtils.requireString(json, 'mime_type'),
      criadoEm: JsonUtils.requireDateTime(json, 'criado_em'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome_original': nomeOriginal,
    'tipo': tipo.valor,
    'mime_type': mimeType,
    'criado_em': criadoEm.toIso8601String(),
  };

  String get extensaoInferida {
    switch (mimeType) {
      case 'image/png':
        return 'png';
      case 'image/jpeg':
        return 'jpg';
      case 'image/webp':
        return 'webp';
      case 'application/pdf':
        return 'pdf';
      case 'audio/mpeg':
        return 'mp3';
      case 'audio/wav':
        return 'wav';
      case 'audio/ogg':
        return 'ogg';
      case 'video/mp4':
        return 'mp4';
      case 'video/webm':
        return 'webm';
      default:
        return 'bin';
    }
  }
}
