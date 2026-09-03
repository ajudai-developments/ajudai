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

  Future<List<ServicoOferecido>> listarOferecidosPorPrestador(
    String usuarioId,
  ) async {
    final response = await _client
        .from('servicos_oferecidos')
        .select()
        .eq('usuario_id', usuarioId);

    return (response as List)
        .map((r) => ServicoOferecido.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<ObterServicoOferecidoResponseDto?> obterDetalheCompleto(
    String servicoOferecidoId,
  ) async {
    final response = await _client
        .from('servicos_oferecidos')
        .select('''
        *,
        servicos!servicos_oferecidos_servico_id_fkey (
          *,
          categorias!servicos_categoria_id_fkey (*)
        ),
        usuarios!servicos_oferecidos_usuario_id_fkey (*)
      ''')
        .eq('id', servicoOferecidoId)
        .maybeSingle();

    if (response == null) return null;

    final servicoOferecido = ServicoOferecido.fromJson(response);
    final servicoJson = response['servicos'] as Map<String, dynamic>;
    final categoriaJson = servicoJson['categorias'] as Map<String, dynamic>;
    final prestadorJson = response['usuarios'] as Map<String, dynamic>;

    final servico = Servico.fromJson(servicoJson);
    final categoria = Categoria.fromJson(categoriaJson);
    final prestador = Usuario.fromJson(prestadorJson);

    final selosResponse = await _client
        .from('conquistas_usuario')
        .select()
        .eq('usuario_id', prestador.id);
    final selos = (selosResponse as List)
        .map((s) => ConquistaUsuario.fromJson(s as Map<String, dynamic>))
        .toList();

    final avaliacoesResponse = await _client
        .from('avaliacoes_usuario')
        .select('''
        *,
        usuarios!avaliacoes_usuario_avaliador_id_fkey (nome)
      ''')
        .eq('avaliado_id', prestador.id)
        .order('criado_em', ascending: false);

    final avaliacoesRaw = avaliacoesResponse as List;
    final comentarios = avaliacoesRaw.map((r) {
      final map = r as Map<String, dynamic>;
      final avaliadorNome =
          (map['usuarios'] as Map<String, dynamic>)['nome'] as String;
      return AvaliacaoUsuario.fromJson({
        ...map,
        'avaliador_nome': avaliadorNome,
      });
    }).toList();

    final quantidadeAvaliacoes = comentarios.length;
    final mediaAvaliacao = quantidadeAvaliacoes == 0
        ? null
        : comentarios.map((c) => c.avaliacao).reduce((a, b) => a + b) /
              quantidadeAvaliacoes;

    return ObterServicoOferecidoResponseDto(
      servicoOferecido: servicoOferecido,
      servico: servico,
      categoria: categoria,
      prestador: prestador,
      selos: selos,
      mediaAvaliacao: mediaAvaliacao,
      quantidadeAvaliacoes: quantidadeAvaliacoes,
      comentarios: comentarios.take(10).toList(),
    );
  }

  Future<List<ServicoOferecidoPreview>> listarServicosPorCategoria(
    String categoriaId,
  ) async {
    final response = await _client.rpc(
      'listar_servicos_por_categoria',
      params: {'p_categoria_id': categoriaId},
    );

    final lista = (response as List).cast<Map<String, dynamic>>();
    return lista.map(ServicoOferecidoPreview.fromJson).toList();
  }
}
