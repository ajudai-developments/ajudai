import 'package:supabase/supabase.dart';

class ChatRepository {
  final SupabaseClient _client;
  ChatRepository(this._client);

  Future<String> criarConversa({required String idPrestador}) async {
    final resultado = await _client.rpc(
      'criar_conversa',
      params: {'p_prestador_id': idPrestador},
    );
    return resultado as String;
  }

  Future<List<Map<String, dynamic>>> listarConversasComDetalhes() async {
    final resultado = await _client.rpc('listar_conversas_com_detalhes');
    return (resultado as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> enviarMensagem({
    required String idConversa,
    String? texto,
    required String tipo,
  }) async {
    final resultado = await _client.rpc(
      'enviar_mensagem',
      params: {'p_conversa_id': idConversa, 'p_texto': texto, 'p_tipo': tipo},
    );
    return resultado as Map<String, dynamic>;
  }

  Future<String> registrarArquivoMensagem({
    required String mensagemId,
    required String nomeOriginal,
    required String tipoArquivo,
    required String mimeType,
  }) async {
    final resultado = await _client.rpc(
      'registrar_mensagem_arquivo',
      params: {
        'p_mensagem_id': mensagemId,
        'p_nome_original': nomeOriginal,
        'p_tipo': tipoArquivo,
        'p_mime_type': mimeType,
      },
    );
    return resultado as String;
  }

  Future<Map<String, dynamic>?> buscarParticipantes(String conversaId) async {
    return await _client
        .from('conversas')
        .select('usuario_a_id, usuario_b_id')
        .eq('id', conversaId)
        .maybeSingle();
  }

  Future<List<Map<String, dynamic>>> listarMensagens(
    String conversaId, {
    DateTime? antesDe,
    int limite = 50,
  }) async {
    final resultado = await _client.rpc(
      'listar_mensagens_conversa',
      params: {
        'p_conversa_id': conversaId,
        'p_antes_de': antesDe?.toIso8601String(),
        'p_limite': limite,
      },
    );
    return (resultado as List).cast<Map<String, dynamic>>();
  }
}
