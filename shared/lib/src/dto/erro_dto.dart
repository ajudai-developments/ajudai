import 'ws_message.dart';

enum ErroCodigo {
  naoAutenticado,
  credenciaisInvalidas,
  sessaoExpirada,
  dadosInvalidos,
  emailJaCadastrado,
  cpfJaCadastrado,
  erroInterno,
}

class ErroDto implements WsMessage {
  final ErroCodigo codigo;
  final String mensagem;

  ErroDto({required this.codigo, required this.mensagem});

  @override
  String get tipo => 'erro';

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo,
    'codigo': codigo.name,
    'mensagem': mensagem,
  };
}
