  import 'package:shared/shared.dart';

import '../../core/session/sessao.dart';
import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

/// Repositório de prestador.
///
/// LIMITAÇÃO DE BACKEND: não existe DTO de editar ou remover um serviço
/// oferecido — só criar e listar. Uma vez criado, o serviço fica assim
/// até o backend ganhar esses endpoints.
class PrestadorRepository {
  /// Solicita virar prestador. Atualiza a Sessao com o usuário retornado
  /// (o `statusPrestador` deve vir como `pendente`), mesmo padrão de
  /// AuthRepository/UsuarioRepository.
  Future<SolicitarPrestadorResponseDto> solicitarPrestador() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(SolicitarPrestadorRequestDto());

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.solicitarPrestadorOk);
    final resposta = SolicitarPrestadorResponseDto.fromJson(json);

    Sessao.instance.definirUsuario(resposta.usuario);
    return resposta;
  }

  Future<ServicoOferecido> criarServicoOferecido({
    required String servicoId,
    required String descricao,
    required double valor,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      CriarServicoOferecidoRequestDto(
        servicoId: servicoId,
        descricao: descricao,
        valor: valor,
      ),
    );

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.criarServicoOferecidoOk);
    return CriarServicoOferecidoResponseDto.fromJson(json).servicoOferecido;
  }

  Future<List<ServicoOferecido>> listarMeusServicosOferecidos() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(ListarMeusServicosOferecidosRequestDto());

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.listarMeusServicosOferecidosOk);
    return ListarMeusServicosOferecidosResponseDto.fromJson(json).servicosOferecidos;
  }
}