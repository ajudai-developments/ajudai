import 'package:shared/src/dto/tipo_mensagem.dart';

import 'ws_message.dart';

enum ErroCodigo {
  naoAutenticado,
  credenciaisInvalidas,
  sessaoExpirada,
  dadosInvalidos,
  emailJaCadastrado,
  cpfJaCadastrado,
  erroInterno,
  senhaFraca,
}

class ErroDto implements WsMessage {
  final ErroCodigo codigo;
  final String mensagem;

  ErroDto({required this.codigo, required this.mensagem});

  @override
  TipoMensagem get tipo => TipoMensagem.erro;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'codigo': codigo.name,
    'mensagem': mensagem,
  };
}
