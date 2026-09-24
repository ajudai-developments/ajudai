import 'dart:convert';
import 'dart:typed_data';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

class _InfoExtensao {
  final TipoArquivo tipo;
  final String mimeType;
  const _InfoExtensao(this.tipo, this.mimeType);
}

const _extensoesPermitidas = {
  'png': _InfoExtensao(TipoArquivo.imagem, 'image/png'),
  'jpg': _InfoExtensao(TipoArquivo.imagem, 'image/jpeg'),
  'jpeg': _InfoExtensao(TipoArquivo.imagem, 'image/jpeg'),
  'webp': _InfoExtensao(TipoArquivo.imagem, 'image/webp'),
  'pdf': _InfoExtensao(TipoArquivo.documento, 'application/pdf'),
  'mp3': _InfoExtensao(TipoArquivo.audio, 'audio/mpeg'),
  'wav': _InfoExtensao(TipoArquivo.audio, 'audio/wav'),
  'ogg': _InfoExtensao(TipoArquivo.audio, 'audio/ogg'),
  'm4a': _InfoExtensao(TipoArquivo.audio, 'audio/mp4'),
  'mp4': _InfoExtensao(TipoArquivo.video, 'video/mp4'),
  'webm': _InfoExtensao(TipoArquivo.video, 'video/webm'),
};

class ArquivoValidado {
  final List<int> bytes;
  final TipoArquivo tipo;
  final String mimeType;
  ArquivoValidado(this.bytes, this.tipo, this.mimeType);
}

class ArquivoUploadService {
  static const limiteBytesPadrao = 30 * 1024 * 1024;

  static ArquivoValidado? validar(
    ArquivoUpload arquivo, {
    int limiteBytes = limiteBytesPadrao,
  }) {
    final info = _extensoesPermitidas[arquivo.extensao.toLowerCase()];
    if (info == null) return null;

    List<int> bytes;
    try {
      bytes = base64Decode(arquivo.bytesBase64);
    } catch (_) {
      return null;
    }

    if (bytes.isEmpty || bytes.length > limiteBytes) return null;

    return ArquivoValidado(bytes, info.tipo, info.mimeType);
  }

  static Future<void> upload({
    required SupabaseClient client,
    required String bucket,
    required String prefixo,
    required String arquivoId,
    required String extensao,
    required ArquivoValidado validado,
  }) async {
    final path = '$prefixo/$arquivoId.$extensao';
    await client.storage
        .from(bucket)
        .uploadBinary(
          path,
          Uint8List.fromList(validado.bytes),
          fileOptions: FileOptions(contentType: validado.mimeType),
        );
  }

  static Future<String> urlAssinada({
    required SupabaseClient client,
    required String bucket,
    required String prefixo,
    required ArquivoAnexado arquivo,
    int expiraEmSegundos = 3600,
  }) async {
    final path = '$prefixo/${arquivo.id}.${arquivo.extensaoInferida}';
    return client.storage.from(bucket).createSignedUrl(path, expiraEmSegundos);
  }
}
