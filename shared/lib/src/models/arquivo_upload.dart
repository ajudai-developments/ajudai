import 'package:shared/src/dto/json_utils.dart';

class ArquivoUpload {
  final String nomeOriginal;
  final String extensao;
  final String bytesBase64;

  ArquivoUpload({
    required this.nomeOriginal,
    required this.extensao,
    required this.bytesBase64,
  });

  factory ArquivoUpload.fromJson(Map<String, dynamic> json) {
    return ArquivoUpload(
      nomeOriginal: JsonUtils.requireString(json, 'nome_original'),
      extensao: JsonUtils.requireString(json, 'extensao'),
      bytesBase64: JsonUtils.requireString(json, 'bytes_base64'),
    );
  }

  Map<String, dynamic> toJson() => {
    'nome_original': nomeOriginal,
    'extensao': extensao,
    'bytes_base64': bytesBase64,
  };
}
