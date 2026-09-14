import 'package:backend/src/repositories/categoria_repository.dart';
import 'package:backend/src/services/sessao_service.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

class CategoriaService {
  final SessaoService _sessaoService;
  final SupabaseClient _supabaseClient;
  CategoriaService(this._sessaoService, this._supabaseClient);

  Future<ListarCategoriasResponseDto> listarCategorias(
    WsConnection conexao,
  ) async {
    final client = _sessaoService.clientDe(conexao) ?? _supabaseClient;

    final categorias = await CategoriaRepository(client).listarCategorias();

    return ListarCategoriasResponseDto(categorias: categorias);
  }
}
