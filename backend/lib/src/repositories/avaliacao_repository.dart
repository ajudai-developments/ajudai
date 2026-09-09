import 'package:supabase/supabase.dart';

class AvaliacaoRepository {
  final SupabaseClient _client;
  AvaliacaoRepository(this._client);

  Future<void> criarAvaliacaoAgendamento({
    required String agendamentoId,
    required String avaliadorId,
    required double avaliacao,
    String? descricao,
    String? mensagem,
  }) async {
    try {
      await _client.from('avaliacoes_agendamento').insert({
        'agendamento_id': agendamentoId,
        'avaliador_id': avaliadorId,
        'avaliacao': avaliacao,
        'descricao': descricao,
        'mensagem': mensagem,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw ArgumentError('Você já avaliou esse agendamento');
      }
      rethrow;
    }
  }

  Future<void> criarAvaliacaoUsuario({
    required String agendamentoId,
    required String avaliadorId,
    required String avaliadoId,
    required double avaliacao,
    String? descricao,
    String? mensagem,
  }) async {
    try {
      await _client.from('avaliacoes_usuario').insert({
        'agendamento_id': agendamentoId,
        'avaliador_id': avaliadorId,
        'avaliado_id': avaliadoId,
        'avaliacao': avaliacao,
        'descricao': descricao,
        'mensagem': mensagem,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw ArgumentError('Você já avaliou esse usuário');
      }
      rethrow;
    }
  }
}
