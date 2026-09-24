import 'dart:typed_data';
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

  Future<Verificacao> solicitarSerPrestador(String userId) async {
    await _client
        .from('usuarios')
        .update({"status_prestador": StatusPrestador.pendente.toDbValue()})
        .eq('id', userId);

    final solicitacao = await _client.from('verificacoes').insert({
      "usuario_id": userId,
      "solicitado_em": DateTime.now().toUtc().toIso8601String(),
    }).select();

    return Verificacao.fromJson(solicitacao[0]);
  }

  Future<ObterPerfilPublicoResponseDto?> obterPerfilPublico(
    String usuarioId,
  ) async {
    final response = await _client.rpc(
      'obter_perfil_publico_usuario',
      params: {'p_usuario_id': usuarioId},
    );

    if (response == null) return null;

    return ObterPerfilPublicoResponseDto.fromJson(
      response as Map<String, dynamic>,
    );
  }

  Future<PerfilCompleto> obterPerfilCompleto() async {
    final resultado = await _client.rpc('obter_meu_perfil_completo');
    final linha = (resultado as List).first as Map<String, dynamic>;
    return PerfilCompleto.fromJson(linha);
  }

  Future<String> uploadAvatar({
    required String usuarioId,
    required List<int> bytes,
    required String extensao,
    required String mimeType,
  }) async {
    final path = '$usuarioId/avatar.$extensao';
    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(upsert: true, contentType: mimeType),
        );

    final urlBase = _client.storage.from('avatars').getPublicUrl(path);
    final urlComCacheBust =
        '$urlBase?v=${DateTime.now().millisecondsSinceEpoch}';

    await _client
        .from('usuarios')
        .update({'avatar_url': urlComCacheBust})
        .eq('id', usuarioId);

    return urlComCacheBust;
  }

  Future<String> registrarArquivoVerificacao({
    required String verificacaoId,
    required String nomeOriginal,
    required String tipoArquivo,
    required String mimeType,
  }) async {
    final resultado = await _client.rpc(
      'registrar_verificacao_arquivo',
      params: {
        'p_verificacao_id': verificacaoId,
        'p_nome_original': nomeOriginal,
        'p_tipo': tipoArquivo,
        'p_mime_type': mimeType,
      },
    );
    return resultado as String;
  }
}
