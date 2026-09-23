import 'package:shared/shared.dart';

import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

class ConversasRepository {
  Future<String> criarConversa(String prestadorId) async {
    await WsClient.instance.conectar();
    WsClient.instance.enviar(CriarConversaRequestDto(prestadorId: prestadorId));

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.criarConversaOk,
    );

    return CriarConversaResponseDto.fromJson(json).conversaId;
  }

  Future<List<ConversaResumo>> listarConversas() async {
    await WsClient.instance.conectar();
    WsClient.instance.enviar(ListarConversasRequestDto());

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.listarConversasOk,
    );
    return ListarConversasResponseDto.fromJson(json).conversas;
  }

  Future<List<MensagemComUrl>> listarMensagens(String conversaId) async {
    await WsClient.instance.conectar();
    WsClient.instance.enviar(ListarMensagensRequestDto(idConversa: conversaId));

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.listarMensagensOk,
    );
    return ListarMensagensResponseDto.fromJson(json).mensagens;
  }

  Future<MensagemComUrl> enviarMensagem({
    required String conversaId,
    String? texto,
    ArquivoUpload? arquivo,
  }) async {
    await WsClient.instance.conectar();
    WsClient.instance.enviar(
      EnviarMensagemRequestDto(
        idConversa: conversaId,
        texto: texto,
        arquivo: arquivo,
      ),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.enviarMensagemOk,
    );
    return EnviarMensagemResponseDto.fromJson(json).mensagem;
  }

  Stream<MensagemComUrl> escutarNovasMensagens() {
    return WsMessageStream.instance.stream
        .where(
          (json) =>
              TipoMensagem.fromValor(json['tipo'] as String?) ==
              TipoMensagem.novaMensagem,
        )
        .map((json) => NovaMensagemDto.fromJson(json).mensagem);
  }
}
