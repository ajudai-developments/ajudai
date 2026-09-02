import 'package:shared/shared.dart';

class ListarServicosRequestDto implements WsMessage {
  final String? categoriaId;

  ListarServicosRequestDto({this.categoriaId});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicos;

  factory ListarServicosRequestDto.fromJson(Map<String, dynamic> json) =>
      ListarServicosRequestDto(
        categoriaId: JsonUtils.optionalString(json, 'categoriaId'),
      );

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    if (categoriaId != null) 'categoriaId': categoriaId,
  };
}
