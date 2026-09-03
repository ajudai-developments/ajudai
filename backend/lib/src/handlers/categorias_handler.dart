import 'package:backend/src/services/categoria_service.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';
import '../ws/ws_connection.dart';

class CategoriaHandler {
  final CategoriaService _categoriaService;

  CategoriaHandler(this._categoriaService);

  Future<void> handleListarCategorias(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final resposta = await _categoriaService.listarCategorias(conexao);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on PostgrestException catch (e, stackTrace) {
      print('Erro ao listar categorias: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar categorias',
        ),
      );
    } catch (e, stackTrace) {
      print('Erro ao listar categorias: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar categorias',
        ),
      );
    }
  }
}
