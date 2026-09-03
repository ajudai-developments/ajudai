import 'package:supabase/supabase.dart';
import 'package:shared/shared.dart';

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  Future<List<VerificacaoComUsuario>> obterVerificacoes(
    StatusVerificacao status,
  ) async {
    final response = await _client
        .from('verificacoes')
        .select('''
          *, 
          usuarios!verificacoes_usuario_id_fkey (
            nome,
            cpf,
            telefone
          )
        ''')
        .eq('status', status.name);

    return (response as List)
        .map((r) => VerificacaoComUsuario.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<Verificacao> aprovarPrestador({
    required String verificacoId,
    required String adminId,
  }) async {
    final response = await _client
        .from('verificacoes')
        .update({
          "alterado_em": DateTime.now().toUtc().toIso8601String(),
          "alterado_por_admin_id": adminId,
          "status": StatusVerificacao.aprovado.name,
        })
        .eq('id', verificacoId)
        .select()
        .single();

    final verificacao = Verificacao.fromJson(response);

    await _client
        .from('usuarios')
        .update({
          "user_role": UserRole.prestador.name,
          "status_prestador": StatusPrestador.aprovado.toDbValue(),
        })
        .eq('id', verificacao.usuarioId);

    return Verificacao.fromJson(response);
  }

  Future<Verificacao> rejeitarPrestador({
    required String verificacoId,
    required String adminId,
  }) async {
    final response = await _client
        .from('verificacoes')
        .update({
          "alterado_em": DateTime.now().toUtc().toIso8601String(),
          "alterado_por_admin_id": adminId,
          "status": StatusVerificacao.rejeitado.name,
        })
        .eq('id', verificacoId)
        .select()
        .single();

    final verificacao = Verificacao.fromJson(response);

    await _client
        .from('usuarios')
        .update({
          "user_role": UserRole.cliente.name,
          "status_prestador": StatusPrestador.naoSolicitado.toDbValue(),
        })
        .eq('id', verificacao.usuarioId);

    return Verificacao.fromJson(response);
  }
}
