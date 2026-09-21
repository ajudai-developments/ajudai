import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

class ServicoOferecidoDetalhe {
  final String servicoOferecidoId;
  final String servicoNome;
  final String prestadorId;
  final String prestadorNome;
  final double valor;

  ServicoOferecidoDetalhe({
    required this.servicoOferecidoId,
    required this.servicoNome,
    required this.prestadorId,
    required this.prestadorNome,
    required this.valor,
  });
}

class ServicoRepository {
  final SupabaseClient _client;
  ServicoRepository(this._client);

  Future<List<Servico>> listarServicos({String? categoriaId}) async {
    var query = _client.from('servicos').select();
    if (categoriaId != null) query = query.eq('categoria_id', categoriaId);
    final response = await query.order('nome');
    return (response as List).map((e) => Servico.fromJson(e)).toList();
  }

  Future<ServicoOferecidoDetalhe?> obterDetalheParaAgendamento(
    String servicoOferecidoId,
  ) async {
    final response = await _client
        .from('servicos_oferecidos')
        .select('''
    id, valor,
    servicos(nome),
    usuarios(id, nome, status_prestador)
  ''')
        .eq('id', servicoOferecidoId)
        .maybeSingle();

    if (response == null) return null;

    final usuario = response['usuarios'] as Map<String, dynamic>;

    if (usuario['status_prestador'] != 'aprovado') return null;

    return ServicoOferecidoDetalhe(
      servicoOferecidoId: response['id'] as String,
      servicoNome:
          (response['servicos'] as Map<String, dynamic>)['nome'] as String,
      prestadorId: usuario['id'] as String,
      prestadorNome: usuario['nome'] as String,
      valor: (response['valor'] as num).toDouble(),
    );
  }

  Future<ServicoOferecido> criarOferecido({
    required String servicoId,
    required String usuarioId,
    required String descricao,
    required double valor,
  }) async {
    final response = await _client
        .from('servicos_oferecidos')
        .insert({
          'servico_id': servicoId,
          'usuario_id': usuarioId,
          'descricao': descricao,
          'valor': valor,
        })
        .select()
        .single();

    return ServicoOferecido.fromJson(response);
  }

  Future<List<ServicoOferecidoResumo>> listarOferecidosPorPrestador(
    String usuarioId,
  ) async {
    final response = await _client.rpc(
      'listar_servicos_oferecidos_do_prestador',
      params: {'p_prestador_id': usuarioId},
    );

    return (response as List)
        .map((r) => ServicoOferecidoResumo.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<ServicoOferecidoResumo>> listarServicosDesativadosDoPrestador(
    String usuarioId,
  ) async {
    final response = await _client.rpc(
      'listar_servicos_oferecidos_do_prestador_desativados',
      params: {'p_prestador_id': usuarioId},
    );

    return (response as List)
        .map((r) => ServicoOferecidoResumo.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<ObterServicoOferecidoResponseDto?> obterDetalheCompleto(
    String servicoOferecidoId,
  ) async {
    final response = await _client.rpc(
      "obter_detalhe_servico_oferecido",
      params: {"p_servico_oferecido_id": servicoOferecidoId},
    );

    return ObterServicoOferecidoResponseDto.fromJson(
      response as Map<String, dynamic>,
    );
  }

  Future<List<ServicoOferecidoPreview>> listarServicosOferecidosPorCategoria(
    String categoriaId, {
    String? usuarioAtualId,
  }) async {
    final response = await _client.rpc(
      'listar_servicos_oferecidos_por_categoria_id',
      params: {
        'p_categoria_id': categoriaId,
        'p_usuario_atual_id': ?usuarioAtualId,
      },
    );

    final lista = (response as List).cast<Map<String, dynamic>>();
    return lista.map(ServicoOferecidoPreview.fromJson).toList();
  }

  Future<List<ServicoOferecidoPreview>> listarServicosOferecidosPorservico(
    String servicoId, {
    String? usuarioAtualId,
  }) async {
    try {
      final response = await _client.rpc(
        'listar_servicos_oferecidos_por_servico_id',
        params: {
          'p_servico_id': servicoId,
          'p_usuario_atual_id': ?usuarioAtualId,
        },
      );

      final lista = (response as List).cast<Map<String, dynamic>>();
      return lista.map(ServicoOferecidoPreview.fromJson).toList();
    } catch (e, st) {
      print('RPC ERRO: $e');
      print(st);
      rethrow;
    }
  }

  Future<ServicoOferecido> atualizarServico(
    String servicoOferecidoId, {
    required String usuarioId,
    String? descricao,
    double? valor,
  }) async {
    final response = await _client
        .from('servicos_oferecidos')
        .update({'descricao': ?descricao, 'valor': ?valor})
        .eq('id', servicoOferecidoId)
        .eq('usuario_id', usuarioId)
        .select()
        .single();

    return ServicoOferecido.fromJson(response);
  }

  Future<void> desativarServicoOferecido(
    String servicoOferecidoId, {
    required String usuarioId,
  }) async {
    await _client
        .from('servicos_oferecidos')
        .update({"ativo": false})
        .eq('id', servicoOferecidoId)
        .eq('usuario_id', usuarioId);
  }

  Future<void> ativarServicoOferecido(
    String servicoOferecidoId, {
    required String usuarioId,
  }) async {
    await _client
        .from('servicos_oferecidos')
        .update({"ativo": true})
        .eq('id', servicoOferecidoId)
        .eq('usuario_id', usuarioId);
  }
}
