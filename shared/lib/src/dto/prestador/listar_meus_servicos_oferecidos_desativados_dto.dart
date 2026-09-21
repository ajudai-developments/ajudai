import 'package:shared/shared.dart';

class ListarMeusServicosOferecidosDesativadosRequestDto implements WsMessage {
  @override
  TipoMensagem get tipo => TipoMensagem.listarMeusServicosOferecidosDesativados;

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class ListarMeusServicosOferecidosDesativadosResponseDto implements WsMessage {
  final List<ServicoOferecidoResumo> servicosOferecidos;
  ListarMeusServicosOferecidosDesativadosResponseDto({
    required this.servicosOferecidos,
  });

  @override
  TipoMensagem get tipo =>
      TipoMensagem.listarMeusServicosOferecidosDesativadosOk;

  factory ListarMeusServicosOferecidosDesativadosResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final lista = JsonUtils.requireListaDeMapas(
      json,
      'servicos_oferecidos_desativados',
    );
    return ListarMeusServicosOferecidosDesativadosResponseDto(
      servicosOferecidos: lista.map(ServicoOferecidoResumo.fromJson).toList(),
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servicos_oferecidos_desativados': servicosOferecidos
        .map((s) => s.toJson())
        .toList(),
  };
}
