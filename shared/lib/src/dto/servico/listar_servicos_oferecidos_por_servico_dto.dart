import 'package:shared/shared.dart';

class ListarServicosOferecidosPorServicoRequestDto implements WsMessage {
  final String servicoId;

  ListarServicosOferecidosPorServicoRequestDto({required this.servicoId});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicoOferecidoPorServico;

  factory ListarServicosOferecidosPorServicoRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarServicosOferecidosPorServicoRequestDto(
      servicoId: JsonUtils.requireString(json, 'categoria_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_id': servicoId,
  };
}

class ListarServicosOferecidosPorServicoResponseDto implements WsMessage {
  final List<ServicoOferecidoPreview> servicos;

  ListarServicosOferecidosPorServicoResponseDto({required this.servicos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicoOferecidoPorServicoOk;

  factory ListarServicosOferecidosPorServicoResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final lista = JsonUtils.requireListaDeMapas(json, 'servicos_oferecidos');
    return ListarServicosOferecidosPorServicoResponseDto(
      servicos: lista.map(ServicoOferecidoPreview.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servicos_oferecidos': servicos.map((s) => s.toJson()).toList(),
  };
}
