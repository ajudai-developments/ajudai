import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

/// Filtros simples para o feed/busca de serviços oferecidos.
class ListarServicosOferecidosRequestDto implements WsMessage {
  final String? categoriaId;
  final String? servicoId;
  final String? cidade;

  ListarServicosOferecidosRequestDto({
    this.categoriaId,
    this.servicoId,
    this.cidade,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicosOferecidos;

  factory ListarServicosOferecidosRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarServicosOferecidosRequestDto(
      categoriaId: JsonUtils.optionalString(json, 'categoria_id'),
      servicoId: JsonUtils.optionalString(json, 'servico_id'),
      cidade: JsonUtils.optionalString(json, 'cidade'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'categoria_id': categoriaId,
    'servico_id': servicoId,
    'cidade': cidade,
  };
}
