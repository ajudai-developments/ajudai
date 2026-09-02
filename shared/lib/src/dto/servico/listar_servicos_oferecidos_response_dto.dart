import 'package:shared/shared.dart';

class ListarServicosOferecidosResponseDto implements WsMessage {
  final List<ServicoOferecidoPreview> servicosOferecidos;

  ListarServicosOferecidosResponseDto({required this.servicosOferecidos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicosOferecidosOk;

  factory ListarServicosOferecidosResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final lista = JsonUtils.requireListaDeMapas(
      json,
      'servicos_oferecidos',
    );
    return ListarServicosOferecidosResponseDto(
      servicosOferecidos: lista.map(ServicoOferecidoPreview.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servicos_oferecidos': servicosOferecidos
        .map((s) => s.toJson())
        .toList(),
  };
}
