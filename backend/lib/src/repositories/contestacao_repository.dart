import 'package:supabase/supabase.dart';
import 'package:shared/shared.dart';

class ContestacaoRepository {
  final SupabaseClient _client;
  ContestacaoRepository(this._client);

  Future<String> criarContestacao({
    required String agendamentoId,
    required String descricao,
  }) async {
    final resultado = await _client.rpc(
      'criar_contestacao',
      params: {'p_agendamento_id': agendamentoId, 'p_descricao': descricao},
    );

    await _client
        .from('agendamentos')
        .update({'status': 'contestado'})
        .eq('id', agendamentoId);

    return resultado as String;
  }

  Future<String> registrarArquivo({
    required String contestacaoId,
    required String nomeOriginal,
    required String tipoArquivo,
    required String mimeType,
  }) async {
    final resultado = await _client.rpc(
      'registrar_contestacao_arquivo',
      params: {
        'p_contestacao_id': contestacaoId,
        'p_nome_original': nomeOriginal,
        'p_tipo': tipoArquivo,
        'p_mime_type': mimeType,
      },
    );
    return resultado as String;
  }

  Future<List<ContestacaoComDetalhes>> listarMinhasContestacoes(
    String usuarioId,
  ) async {
    final response = await _client.rpc(
      'listar_minhas_contestacoes',
      params: {'p_usuario_id': usuarioId},
    );

    final lista = (response as List).cast<Map<String, dynamic>>();
    return lista.map(ContestacaoComDetalhes.fromJson).toList();
  }
}
