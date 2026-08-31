import 'package:shared/src/dto/tipo_mensagem.dart';

abstract class WsMessage {
  TipoMensagem get tipo;

  Map<String, dynamic> toJson();
}
