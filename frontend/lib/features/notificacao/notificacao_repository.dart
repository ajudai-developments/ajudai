import 'package:shared/shared.dart';

import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

/// Repositório de notificações.
///
/// `NotificacaoDto` agora vem com `id` (opcional só porque a mesma
/// classe também é usada como PUSH de notificação nova — ver
/// `escutarNotificacoesPush` — onde o id pode não ter sido persistido
/// ainda no momento do envio). Toda notificação vinda de
/// `listarMinhasNotificacoes` tem `id` preenchido, já que veio do banco.
class NotificacaoRepository {
  Future<List<NotificacaoDto>> listarMinhasNotificacoes() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(ListarMinhasNotificacoesRequestDto());

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.listarNotificacoesOk,
    );
    return ListarMinhasNotificacoesResponseDto.fromJson(json).notificacoes;
  }

  Future<void> marcarComoLida(String notificacaoId) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      MarcarNotificacaoComoLidaRequestDto(notificacaoId: notificacaoId),
    );

    await WsMessageStream.instance.aguardar(
      TipoMensagem.marcarNotificacaoComoLidaOk,
    );
  }

  Future<void> marcarTodasComoLidas() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(const MarcarTodasNotificacoesComoLidaRequestDto());

    await WsMessageStream.instance.aguardar(
      TipoMensagem.marcarTodasNotificacoesComoLidaOk,
    );
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
