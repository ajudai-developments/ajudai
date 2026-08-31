import 'package:supabase/supabase.dart';
import 'package:shared/shared.dart';

class UsuarioRepository {
  final SupabaseClient _client;

  UsuarioRepository(this._client);

  Future<Usuario?> buscarPorId(String id) async {
    final response = await _client
        .from('usuarios')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Usuario.fromJson(response);
  }

  Future<void> atualizar(String id, Map<String, dynamic> dados) async {
    await _client.from('usuarios').update(dados).eq('id', id);
  }
}
