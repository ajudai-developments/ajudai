import 'package:shared/shared.dart';

class ListarMeusServicosOferecidosRequestDto implements WsMessage {
  @override
  TipoMensagem get tipo => TipoMensagem.listarMeusServicosOferecidos;

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class ListarMeusServicosOferecidosResponseDto implements WsMessage {
  final List<ServicoOferecidoResumo> servicosOferecidos;
  ListarMeusServicosOferecidosResponseDto({required this.servicosOferecidos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarMeusServicosOferecidosOk;

  factory ListarMeusServicosOferecidosResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final lista = JsonUtils.requireListaDeMapas(json, 'servicos_oferecidos');
    return ListarMeusServicosOferecidosResponseDto(
      servicosOferecidos: lista.map(ServicoOferecidoResumo.fromJson).toList(),
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servicos_oferecidos': servicosOferecidos.map((s) => s.toJson()).toList(),
  };
}
