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
    required String texto,
  }) async {
    final resultado = await _client.rpc(
      'enviar_mensagem',
      params: {'p_conversa_id': idConversa, 'p_texto': texto},
    );
    return resultado as Map<String, dynamic>;
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
    var query = _client
        .from('mensagens')
        .select()
        .eq('conversa_id', conversaId);
    if (antesDe != null) {
      query = query.lt('enviado_em', antesDe.toIso8601String());
    }
    return await query.order('enviado_em', ascending: false).limit(limite);
  }
}
