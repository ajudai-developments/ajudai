import 'package:backend/src/services/sessao_service.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

class ConquistaListener {
  final SupabaseClient _client;
  final SessaoService _sessaoService;

  ConquistaListener({required this._client, required this._sessaoService});

  void iniciar() {
    _client
        .channel('conquistas_usuario_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'conquistas_usuario',
          callback: (payload) async {
            final usuarioId = payload.newRecord['usuario_id'] as String;
            final conquistaId = payload.newRecord['conquista_id'] as String;

            final conquista = await _buscarConquista(conquistaId);
            if (conquista == null) return;

            _sessaoService.enviarParaUsuario(
              usuarioId,
              NotificacaoDto(
                titulo: 'Nova conquista desbloqueada!',
                mensagem: '${conquista['nome']} — ${conquista['descricao']}',
                categoria: CategoriaNotificacao.geral,
                dados: {'conquista_id': conquistaId},
              ),
            );
          },
        )
        .subscribe();
  }

  Future<Map<String, dynamic>?> _buscarConquista(String conquistaId) async {
    return await _client
        .from('conquistas')
        .select('nome, descricao')
        .eq('id', conquistaId)
        .maybeSingle();
  }
}
