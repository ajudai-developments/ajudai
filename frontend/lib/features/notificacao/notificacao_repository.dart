import 'package:shared/shared.dart';

import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

/// Repositório de notificações.
///
/// LIMITAÇÃO DE BACKEND: `NotificacaoDto` só tem `titulo`/`mensagem`/
/// `dados` — sem `id`, sem `criadoEm`, sem `lida`, mesmo a tabela tendo
/// essas colunas. Consequências pro frontend:
/// - não dá pra ordenar a lista por data (a ordem vem do servidor,
///   presumivelmente mais recente primeiro, mas não é garantido aqui);
/// - não dá pra marcar uma notificação específica como lida (não tem id
///   pra referenciar, nem TipoMensagem de "marcar como lida");
/// - não dá pra mostrar indicador visual de "não lida" (nenhum contador
///   nem badge é possível hoje).
class NotificacaoRepository {
  Future<List<NotificacaoDto>> listarMinhasNotificacoes() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(ListarMinhasNotificacoesRequestDto());

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.listarNotificacoesOk,
    );
    return ListarMinhasNotificacoesResponseDto.fromJson(json).notificacoes;
  }

  /// Notificações que chegam a QUALQUER momento via push
  /// (`TipoMensagem.notificacao`), sem o cliente ter pedido — diferente
  /// de `listarMinhasNotificacoes`, que é sob demanda.
  ///
  /// Ainda não usado em nenhuma tela (poderia alimentar um badge de
  /// contagem em algum ícone, por exemplo) — só deixei pronto pra quando
  /// for necessário.
  Stream<NotificacaoDto> escutarNotificacoesPush() {
    return WsMessageStream.instance.stream
        .where(
          (json) =>
              TipoMensagem.fromValor(json['tipo'] as String?) ==
              TipoMensagem.notificacao,
        )
        .map(NotificacaoDto.fromJson);
  }
}
