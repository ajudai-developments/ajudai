import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class ListarCategoriasRequestDto implements WsMessage {
  ListarCategoriasRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.listarCategorias;

  factory ListarCategoriasRequestDto.fromJson(Map<String, dynamic> json) {
    return ListarCategoriasRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}
