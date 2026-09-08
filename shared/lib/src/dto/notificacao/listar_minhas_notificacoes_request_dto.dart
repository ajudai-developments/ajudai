import '../tipo_mensagem.dart';
import '../ws_message.dart';

class ListarMinhasNotificacoesRequestDto implements WsMessage {
  ListarMinhasNotificacoesRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.listarNotificacoes;

  factory ListarMinhasNotificacoesRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarMinhasNotificacoesRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {"tipo": tipo.valor};
}
