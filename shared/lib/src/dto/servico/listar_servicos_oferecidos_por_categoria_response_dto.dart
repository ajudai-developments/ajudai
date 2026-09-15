import 'package:shared/shared.dart';

class ListarServicosOferecidosPorCategoriaResponseDto implements WsMessage {
  final List<ServicoOferecidoPreview> servicos;

  ListarServicosOferecidosPorCategoriaResponseDto({required this.servicos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicosOferecidosOk;

  factory ListarServicosOferecidosPorCategoriaResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final lista = JsonUtils.requireListaDeMapas(json, 'servicos_oferecidos');
    return ListarServicosOferecidosPorCategoriaResponseDto(
      servicos: lista.map(ServicoOferecidoPreview.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servicos_oferecidos': servicos.map((s) => s.toJson()).toList(),
  };
}
