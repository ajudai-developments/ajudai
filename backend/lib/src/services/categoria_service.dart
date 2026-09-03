import 'package:backend/src/repositories/categoria_repository.dart';
import 'package:backend/src/services/sessao_service.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';

class CategoriaService {
  final SessaoService _sessaoService;
  CategoriaService(this._sessaoService);

  Future<ListarCategoriasResponseDto> listarCategorias(
    WsConnection conexao,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final categorias = await CategoriaRepository(client).listarCategorias();

    return ListarCategoriasResponseDto(categorias: categorias);
  }
}
