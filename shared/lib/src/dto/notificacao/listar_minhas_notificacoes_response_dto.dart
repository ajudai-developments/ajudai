import 'package:shared/shared.dart';

class ListarMinhasNotificacoesResponseDto implements WsMessage {
  final List<NotificacaoDto> notificacoes;
  ListarMinhasNotificacoesResponseDto({required this.notificacoes});

  @override
  TipoMensagem get tipo => TipoMensagem.listarNotificacoesOk;

  factory ListarMinhasNotificacoesResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarMinhasNotificacoesResponseDto(
      notificacoes: JsonUtils.requireListaDeMapas(
        json,
        'notificacoes',
      ).map((e) => NotificacaoDto.fromJson(e)).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "tipo": tipo.valor,
    "notificacoes": notificacoes.map((e) => e.toJson()).toList(),
  };
}
