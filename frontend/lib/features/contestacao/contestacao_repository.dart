import 'package:shared/shared.dart';

import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

class ContestacaoRepository {
  Future<CriarContestacaoResponseDto> criarContestacao({
    required String agendamentoId,
    required String descricao,
    List<ArquivoUpload> arquivos = const [],
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      CriarContestacaoRequestDto(
        agendamentoId: agendamentoId,
        descricao: descricao,
        arquivos: arquivos,
      ),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.criarContestacaoOk,
    );
    return CriarContestacaoResponseDto.fromJson(json);
  }
}
