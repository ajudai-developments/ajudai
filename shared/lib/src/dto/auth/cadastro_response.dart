import 'package:shared/src/dto/tipo_mensagem.dart';

import '../ws_message.dart';

class CadastroResponseDto implements WsMessage {
  final String userId;

  CadastroResponseDto({required this.userId});

  @override
  TipoMensagem get tipo => TipoMensagem.cadastroOk;

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, 'userId': userId};
}
