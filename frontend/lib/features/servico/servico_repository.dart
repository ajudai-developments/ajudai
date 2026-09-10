import 'package:shared/shared.dart';

import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

/// Repositório de serviços: categorias, listagem de serviços de uma
/// categoria, e detalhe completo de um serviço oferecido.
///
/// Fonte única de verdade para "categorias" no app — HomeScreen e
/// CategoriasScreen usam este repositório, em vez de cada uma ter sua
/// própria cópia da chamada.
class ServicoRepository {
  Future<List<Categoria>> listarCategorias() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(ListarCategoriasRequestDto());

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.listarCategoriasOk);
    return ListarCategoriasResponseDto.fromJson(json).categorias;
  }

  Future<List<ServicoOferecidoPreview>> listarServicos({
    required String categoriaId,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance
        .enviar(ListarServicosRequestDto(categoriaId: categoriaId));

    final json =
        await WsMessageStream.instance.aguardar(TipoMensagem.listarServicosOk);
    return ListarServicosResponseDto.fromJson(json).servicos;
  }

  Future<ObterServicoOferecidoResponseDto> obterServicoOferecido({
    required String servicoOferecidoId,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      ObterServicoOferecidoRequestDto(servicoOferecidoId: servicoOferecidoId),
    );

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.obterServicoOferecidoOk);
    return ObterServicoOferecidoResponseDto.fromJson(json);
  }
}