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

class CategoriaRepository {
  final SupabaseClient _client;
  CategoriaRepository(this._client);

  Future<List<Categoria>> listarCategorias() async {
    final response = await _client.from('categorias').select().order('nome');
    return (response as List).map((e) => Categoria.fromJson(e)).toList();
  }
}
