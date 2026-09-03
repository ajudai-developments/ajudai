import 'package:supabase/supabase.dart';
import 'package:shared/shared.dart';

class EnderecoRepository {
  final SupabaseClient _client;

  EnderecoRepository(this._client);

  Future<Endereco> criar({
    required String usuarioId,
    required String nome,
    required String cep,
    required String numero,
    String? complemento,
    required String logradouro,
    required String bairro,
    required String cidade,
    required String estado,
  }) async {
    final response = await _client
        .from('enderecos')
        .insert({
          'usuario_id': usuarioId,
          'nome': nome,
          'cep': cep,
          'numero': numero,
          'complemento': complemento,
          'logradouro': logradouro,
          'bairro': bairro,
          'cidade': cidade,
          'estado': estado,
        })
        .select()
        .single();

    return Endereco.fromJson(response);
  }

  Future<List<Endereco>> obterEnderecoDe({required String userId}) async {
    final response = await _client
        .from('enderecos')
        .select()
        .eq('usuario_id', userId);
    final enderecos = (response as List)
        .map((e) => Endereco.fromJson(e as Map<String, dynamic>))
        .toList();

    return enderecos;
  }

  Future<Endereco?> editarEndereco({
    required String enderecoId,
    required String usuarioId,
    required String nome,
    required String cep,
    required String numero,
    String? complemento,
    required String logradouro,
    required String bairro,
    required String cidade,
    required String estado,
  }) async {
    final response = await _client
        .from('enderecos')
        .update({
          'nome': nome,
          'cep': cep,
          'numero': numero,
          'complemento': complemento,
          'logradouro': logradouro,
          'bairro': bairro,
          'cidade': cidade,
          'estado': estado,
          'editado_em': DateTime.now().toIso8601String(),
        })
        .eq('id', enderecoId)
        .eq('usuario_id', usuarioId)
        .select()
        .maybeSingle();

    if (response == null) return null;

    return Endereco.fromJson(response);
  }

  Future<Endereco?> buscarPorId(String id) async {
    final response = await _client
        .from('enderecos')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response != null ? Endereco.fromJson(response) : null;
  }
}
