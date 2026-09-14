import 'package:shared/shared.dart';

class ListarServicosRequestDto implements WsMessage {
  final String categoriaId;

  ListarServicosRequestDto({required this.categoriaId});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicos;

  factory ListarServicosRequestDto.fromJson(Map<String, dynamic> json) {
    return ListarServicosRequestDto(
      categoriaId: JsonUtils.requireString(json, 'categoria_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'categoria_id': categoriaId,
  };
}

class ListarServicosResponseDto implements WsMessage {
  final List<Servico> servicos;

  ListarServicosResponseDto({required this.servicos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarMeusServicosOferecidosOk;

  factory ListarServicosResponseDto.fromJson(Map<String, dynamic> json) {
    final lista = JsonUtils.requireListaDeMapas(json, 'servicos');
    return ListarServicosResponseDto(
      servicos: lista.map(Servico.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servicos': servicos.map((s) => s.toJson()).toList(),
  };
}
