import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

class NotificacaoRepository {
  final SupabaseClient _client;
  NotificacaoRepository(this._client);

  Future<String> salvar({
    required String usuarioId,
    required String titulo,
    required String mensagem,
    Map<String, dynamic>? dados,
  }) async {
    final response = await _client
        .from('notificacoes')
        .insert({
          'usuario_id': usuarioId,
          'titulo': titulo,
          'mensagem': mensagem,
          'dados': dados,
        })
        .select('id')
        .single();

    return (response)['id'] as String;
  }

  Future<List<NotificacaoDto>> listarNaoLidas(String usuarioId) async {
    final response = await _client
        .from('notificacoes')
        .select()
        .eq('usuario_id', usuarioId)
        .eq('lida', false)
        .order('criado_em', ascending: false);

    return (response as List)
        .map((e) => NotificacaoDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> marcarComoLida({
    required String usuarioId,
    required String notificacaoId,
  }) async {
    final response = await _client
        .from('notificacoes')
        .update({'lida': true})
        .eq('id', notificacaoId)
        .eq('usuario_id', usuarioId)
        .eq('lida', false)
        .select('id');

    return (response as List).isNotEmpty;
  }

  Future<void> marcarTodasComoLidas(String usuarioId) async {
    await _client
        .from('notificacoes')
        .update({'lida': true})
        .eq('usuario_id', usuarioId)
        .eq('lida', false);
  }
}
