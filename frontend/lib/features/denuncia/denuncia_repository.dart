import 'package:shared/shared.dart';

import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

class DenunciaRepository {
  Future<CriarDenunciaResponseDto> criarDenuncia({
    required String usuarioId,
    required TipoDenuncia tipoDenuncia,
    required String descricao,
    List<ArquivoUpload> arquivos = const [],
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      CriarDenunciaRequestDto(
        usuarioId: usuarioId,
        tipoDenuncia: tipoDenuncia,
        descricao: descricao,
        arquivos: arquivos,
      ),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.criarDenunciaOk,
    );
    return CriarDenunciaResponseDto.fromJson(json);
  }
}
