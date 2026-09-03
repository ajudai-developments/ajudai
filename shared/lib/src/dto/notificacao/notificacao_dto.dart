// shared/lib/src/dto/notificacao/notificacao_dto.dart
import '../tipo_mensagem.dart';
import '../ws_message.dart';

class NotificacaoDto implements WsMessage {
  final String titulo;
  final String mensagem;
  final Map<String, dynamic>? dados;

  NotificacaoDto({required this.titulo, required this.mensagem, this.dados});

  @override
  TipoMensagem get tipo => TipoMensagem.notificacao;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'titulo': titulo,
    'mensagem': mensagem,
    if (dados != null) 'dados': dados,
  };
}
