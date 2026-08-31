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

  Future<bool> cpfJaExiste(String cpfLimpo) async {
    final response = await _client
        .from('usuarios')
        .select('id')
        .eq('cpf', cpfLimpo)
        .maybeSingle();

    return response != null;
  }

  Future<Usuario> atualizarPerfil({String? nome, String? telefone}) async {
    final response = await _client.rpc(
      'atualizar_perfil_usuario',
      params: {'p_nome': ?nome, 'p_telefone': ?telefone},
    );

    return Usuario.fromJson(response as Map<String, dynamic>);
  }
}
