import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class ListarServicosRequestDto implements WsMessage {
  final String? categoriaId;

  ListarServicosRequestDto({this.categoriaId});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicos;

  factory ListarServicosRequestDto.fromJson(Map<String, dynamic> json) {
    return ListarServicosRequestDto(
      categoriaId: JsonUtils.optionalString(json, 'categoria_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'categoria_id': categoriaId,
  };
}
