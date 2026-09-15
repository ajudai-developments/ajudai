import 'package:shared/shared.dart';

import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

/// Repositório de serviços: categorias, ofertas de uma categoria,
/// catálogo de tipos de serviço, e detalhe completo de um serviço
/// oferecido.
///
/// Fonte única de verdade para "categorias" no app — HomeScreen e
/// CategoriasScreen usam este repositório, em vez de cada uma ter sua
/// própria cópia da chamada.
///
/// Funil real (corrigido): Categoria -> Ofertas (`listarServicosOferecidos`,
/// usado pelo CLIENTE navegando/agendando) — NÃO passa por "tipo de
/// serviço" nesse caminho, porque o request de ofertas já filtra por
/// categoria inteira, não por um tipo específico.
///
/// `listarServicos` (catálogo de `Servico`, com id+nome) é uma chamada
/// SEPARADA, usada só pelo PRESTADOR em form_servico_oferecido_screen.dart
/// pra escolher o `servicoId` ao criar uma nova oferta — não faz parte
/// da navegação do cliente.
class ServicoRepository {
  Future<List<Categoria>> listarCategorias() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(ListarCategoriasRequestDto());

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.listarCategoriasOk,
    );
    return ListarCategoriasResponseDto.fromJson(json).categorias;
  }

  /// Catálogo de tipos de serviço de uma categoria (ex: "Faxina
  /// residencial"). Usado só pelo prestador ao criar uma nova oferta —
  /// não pela navegação do cliente.
  Future<List<Servico>> listarServicos({required String categoriaId}) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      ListarServicosRequestDto(categoriaId: categoriaId),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.listarServicosOk,
    );
    return ListarServicosResponseDto.fromJson(json).servicos;
  }

  /// Ofertas (prestadores + valor + avaliação) de uma categoria inteira.
  /// É isso que o cliente navega/agenda a partir de categorias_screen.
  Future<List<ServicoOferecidoPreview>> listarServicosOferecidos({
    required String categoriaId,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      ListarServicosOferecidosRequestDto(categoriaId: categoriaId),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.listarServicosOferecidosOk,
    );
    return ListarServicosOferecidosResponse.fromJson(json).servicos;
  }

  Future<ObterServicoOferecidoResponseDto> obterServicoOferecido({
    required String servicoOferecidoId,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      ObterServicoOferecidoRequestDto(servicoOferecidoId: servicoOferecidoId),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.obterServicoOferecidoOk,
    );
    return ObterServicoOferecidoResponseDto.fromJson(json);
  }
}
