import 'package:backend/src/models/endereco_resolvido.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

class AgendamentoRepository {
  final SupabaseClient _client;
  AgendamentoRepository(this._client);

  Future<Agendamento> criar({
    required String usuarioId,
    required String prestadorId,
    required String servicoOferecidoId,
    required EnderecoResolvido endereco,
    required DateTime horaInicio,
    required DateTime horaFim,
    required double valor,
  }) async {
    final response = await _client
        .from('agendamentos')
        .insert({
          'usuario_id': usuarioId,
          'prestador_id': prestadorId,
          'servico_oferecido_id': servicoOferecidoId,
          'endereco_id': endereco.id,
          'endereco_logradouro': endereco.logradouro,
          'endereco_numero': endereco.numero,
          'endereco_complemento': endereco.complemento,
          'endereco_bairro': endereco.bairro,
          'endereco_cidade': endereco.cidade,
          'endereco_estado': endereco.estado,
          'endereco_cep': endereco.cep,
          'hora_inicio': horaInicio.toUtc().toIso8601String(),
          'hora_fim': horaFim.toUtc().toIso8601String(),
          'valor': valor,
        })
        .select()
        .single();

    return Agendamento.fromJson(response);
  }
}
