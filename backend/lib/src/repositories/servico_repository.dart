import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

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
}
