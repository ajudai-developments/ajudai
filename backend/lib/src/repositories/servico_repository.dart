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

  Future<List<Categoria>> listarCategorias() async {
    final response = await _client.from('categorias').select().order('nome');
    return (response as List).map((e) => Categoria.fromJson(e)).toList();
  }

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
}
