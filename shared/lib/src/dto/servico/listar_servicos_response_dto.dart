import 'package:shared/shared.dart';

class ListarServicosResponseDto implements WsMessage {
  final List<ServicoOferecidoPreview> servicos;

  ListarServicosResponseDto({required this.servicos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicosOk;

  factory ListarServicosResponseDto.fromJson(Map<String, dynamic> json) {
    final lista = JsonUtils.requireListaDeMapas(json, 'servicos');
    return ListarServicosResponseDto(
      servicos: lista.map(ServicoOferecidoPreview.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servicos': servicos.map((s) => s.toJson()).toList(),
  };
}
