import 'package:backend/src/models/endereco_resolvido.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

const _statusQueOcupamAgenda = ['pendente', 'aceito', 'em_andamento'];

class AgendamentoRepository {
  final SupabaseClient _client;
  AgendamentoRepository(this._client);

  Future<bool> existeConflito({
    required String prestadorId,
    required DateTime horaInicio,
    required DateTime horaFim,
  }) async {
    final conflitos = await _client
        .from('agendamentos')
        .select('id')
        .eq('prestador_id', prestadorId)
        .inFilter('status', _statusQueOcupamAgenda)
        .lt('hora_inicio', horaFim.toUtc().toIso8601String())
        .gt('hora_fim', horaInicio.toUtc().toIso8601String());

    return (conflitos as List).isNotEmpty;
  }

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

  Future<Agendamento?> buscarPorId(String id) async {
    final response = await _client
        .from('agendamentos')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Agendamento.fromJson(response);
  }

  Future<Agendamento> atualizarStatus({
    required String id,
    required StatusAgendamento status,
    required String alteradoPorUsuarioId,
  }) async {
    final response = await _client
        .from('agendamentos')
        .update({
          'status': status.valor,
          'editado_em': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    final atualizado = Agendamento.fromJson(response);

    await _registrarHistorico(
      atualizado,
      alteradoPorUsuarioId: alteradoPorUsuarioId,
      tipoAlteracao: TipoAlteracaoAgendamento.status,
    );

    return atualizado;
  }

  Future<void> _registrarHistorico(
    Agendamento agendamento, {
    required String alteradoPorUsuarioId,
    required TipoAlteracaoAgendamento tipoAlteracao,
  }) async {
    await _client.from('historico_agendamentos').insert({
      'agendamento_id': agendamento.id,
      'usuario_id': agendamento.usuarioId,
      'prestador_id': agendamento.prestadorId,
      'servico_oferecido_id': agendamento.servicoOferecidoId,
      'endereco_id': agendamento.enderecoId,
      'endereco_logradouro': agendamento.enderecoLogradouro,
      'endereco_numero': agendamento.enderecoNumero,
      'endereco_complemento': agendamento.enderecoComplemento,
      'endereco_bairro': agendamento.enderecoBairro,
      'endereco_cidade': agendamento.enderecoCidade,
      'endereco_estado': agendamento.enderecoEstado,
      'endereco_cep': agendamento.enderecoCep,
      'hora_inicio': agendamento.horaInicio.toUtc().toIso8601String(),
      'hora_fim': agendamento.horaFim.toUtc().toIso8601String(),
      'valor': agendamento.valor,
      'status': agendamento.status.valor,
      'alterado_por_usuario_id': alteradoPorUsuarioId,
      'tipo_alteracao': tipoAlteracao.name,
    });
  }

  Future<List<Agendamento>> listarPorUsuario({
    required String usuarioId,
    List<String>? status,
  }) async {
    var query = _client
        .from('agendamentos')
        .select()
        .eq('usuario_id', usuarioId);
    if (status != null && status.isNotEmpty) {
      query = query.inFilter('status', status);
    }
    final response = await query.order('hora_inicio', ascending: false);
    return (response as List)
        .map((r) => Agendamento.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<Agendamento>> listarPorPrestador({
    required String prestadorId,
    List<String>? status,
  }) async {
    var query = _client
        .from('agendamentos')
        .select()
        .eq('prestador_id', prestadorId);
    if (status != null && status.isNotEmpty) {
      query = query.inFilter('status', status);
    }
    final response = await query.order('hora_inicio', ascending: false);
    return (response as List)
        .map((r) => Agendamento.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
