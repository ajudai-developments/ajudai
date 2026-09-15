import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class ListarServicosOferecidosPorCategoriaRequestDto implements WsMessage {
  final String categoriaId;

  ListarServicosOferecidosPorCategoriaRequestDto({required this.categoriaId});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicosOferecidos;

  factory ListarServicosOferecidosPorCategoriaRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarServicosOferecidosPorCategoriaRequestDto(
      categoriaId: JsonUtils.requireString(json, 'categoria_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'categoria_id': categoriaId,
  };
}
