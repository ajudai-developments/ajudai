// lib/src/features/servicos/data/servico_repository.dart
import 'package:shared/shared.dart';

import '../../../ws/ws_client.dart';

class ServicoRepository {
  final WsClient _wsClient;

  ServicoRepository(this._wsClient);

  Future<List<ServicoOferecidoPreview>> listarServicos({
    String? categoriaId,
  }) async {
    final request = ListarServicosRequestDto(categoriaId: categoriaId!);

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.listarServicosOk.valor},
    );

    final dto = ListarServicosResponseDto.fromJson(response);
    return dto.servicos;
  }

  Future<List<Categoria>> listarCategorias() async {
    final request = ListarCategoriasRequestDto();

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.listarCategoriasOk.valor},
    );

    final dto = ListarCategoriasResponseDto.fromJson(response);
    return dto.categorias;
  }
}
