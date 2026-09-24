import 'package:supabase/supabase.dart';
import 'package:shared/shared.dart';

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  Future<List<VerificacaoComDetalhes>> obterVerificacoes(
    StatusVerificacao status,
  ) async {
    final response = await _client.rpc(
      'admin_listar_verificacoes',
      params: {'p_status': status.name},
    );

    return (response as List)
        .map((r) => VerificacaoComDetalhes.fromJson(r as Map<String, dynamic>))
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

  Future<List<ContestacaoComDetalhes>> listarContestacoes(
    StatusContestacao? status,
  ) async {
    final response = await _client.rpc(
      'admin_listar_contestacoes',
      params: {'p_status': status?.valor},
    );

    return (response as List)
        .map((r) => ContestacaoComDetalhes.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<Contestacao> responderContestacao({
    required String contestacaoId,
    required String adminId,
    required StatusContestacao status,
    required String resposta,
    required StatusAgendamento statusAgendamentoFinal,
  }) async {
    final response = await _client.rpc(
      'admin_responder_contestacao',
      params: {
        'p_contestacao_id': contestacaoId,
        'p_admin_id': adminId,
        'p_status': status.valor,
        'p_resposta': resposta,
        'p_status_agendamento_final': statusAgendamentoFinal.valor,
      },
    );

    return Contestacao.fromJson(response as Map<String, dynamic>);
  }

  Future<List<DenunciaComDetalhes>> listarDenuncias(
    StatusDenuncia? status,
  ) async {
    final response = await _client.rpc(
      'admin_listar_denuncias',
      params: {'p_status': status?.valor},
    );

    return (response as List)
        .map((r) => DenunciaComDetalhes.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<Denuncia> responderDenuncia({
    required String denunciaId,
    required String adminId,
    required StatusDenuncia status,
    required String resposta,
    required bool removerPrestador,
    required bool banirUsuario,
  }) async {
    final response = await _client.rpc(
      'admin_responder_denuncia',
      params: {
        'p_denuncia_id': denunciaId,
        'p_admin_id': adminId,
        'p_status': status.valor,
        'p_resposta': resposta,
        'p_remover_prestador': removerPrestador,
        'p_banir_usuario': banirUsuario,
      },
    );

    return Denuncia.fromJson(response as Map<String, dynamic>);
  }
}
