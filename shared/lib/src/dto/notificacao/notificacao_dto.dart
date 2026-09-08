import 'package:shared/shared.dart';

import '../tipo_mensagem.dart';
import '../ws_message.dart';

class NotificacaoDto implements WsMessage {
  final String titulo;
  final String mensagem;
  final Map<String, dynamic>? dados;

  NotificacaoDto({required this.titulo, required this.mensagem, this.dados});

  @override
  TipoMensagem get tipo => TipoMensagem.notificacao;

  factory NotificacaoDto.fromJson(Map<String, dynamic> json) {
    return NotificacaoDto(
      titulo: JsonUtils.requireString(json, 'titulo'),
      mensagem: JsonUtils.requireString(json, 'mensagem'),
      dados: JsonUtils.optionalMap(json, 'dados'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'titulo': titulo,
    'mensagem': mensagem,
    if (dados != null) 'dados': dados,
  };
}
