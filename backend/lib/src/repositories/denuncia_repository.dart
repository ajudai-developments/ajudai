import 'package:supabase/supabase.dart';

class DenunciaRepository {
  final SupabaseClient _client;
  DenunciaRepository(this._client);

  Future<String> criarDenuncia({
    required String usuarioId,
    required String tipo,
    required String descricao,
  }) async {
    final resultado = await _client.rpc(
      'criar_denuncia',
      params: {
        'p_usuario_id': usuarioId,
        'p_tipo': tipo,
        'p_descricao': descricao,
      },
    );
    return resultado as String;
  }

  Future<String> registrarArquivo({
    required String denunciaId,
    required String nomeOriginal,
    required String tipoArquivo,
    required String mimeType,
  }) async {
    final resultado = await _client.rpc(
      'registrar_denuncia_arquivo',
      params: {
        'p_denuncia_id': denunciaId,
        'p_nome_original': nomeOriginal,
        'p_tipo': tipoArquivo,
        'p_mime_type': mimeType,
      },
    );
    return resultado as String;
  }
}
