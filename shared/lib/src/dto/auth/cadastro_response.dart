import 'package:shared/shared.dart';

class CadastroResponseDto implements WsMessage {
  final Usuario usuario;

  CadastroResponseDto({required this.usuario});

  @override
  TipoMensagem get tipo => TipoMensagem.cadastroOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'usuario': usuario.toJson(),
  };
}
