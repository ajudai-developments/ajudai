import 'package:shared/shared.dart';

import '../../../ws/ws_client.dart';

class CategoriaRepository {
  final WsClient _wsClient;

  CategoriaRepository(this._wsClient);

  Future<List<Categoria>> listarCategorias() async {
    final resposta = await _wsClient.enviarEAguardar(
      ListarCategoriasRequestDto(),
      tiposEsperados: {TipoMensagem.listarCategoriasOk.valor},
    );
    final dto = ListarCategoriasResponseDto.fromJson(resposta);
    return dto.categorias;
  }
}