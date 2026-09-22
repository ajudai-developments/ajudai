import '../tipo_mensagem.dart';
import '../ws_message.dart';

class MarcarTodasNotificacoesComoLidaRequestDto implements WsMessage {
  const MarcarTodasNotificacoesComoLidaRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.marcarTodasNotificacoesComoLida;

  factory MarcarTodasNotificacoesComoLidaRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return const MarcarTodasNotificacoesComoLidaRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class MarcarTodasNotificacoesComoLidaResponseDto implements WsMessage {
  const MarcarTodasNotificacoesComoLidaResponseDto();

  @override
  TipoMensagem get tipo => TipoMensagem.marcarTodasNotificacoesComoLidaOk;

  factory MarcarTodasNotificacoesComoLidaResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return const MarcarTodasNotificacoesComoLidaResponseDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}
