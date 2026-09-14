import 'package:shared/shared.dart';

class ListarServicosOferecidosResponse implements WsMessage {
  final List<ServicoOferecidoPreview> servicos;

  ListarServicosOferecidosResponse({required this.servicos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarMeusServicosOferecidosOk;

  factory ListarServicosOferecidosResponse.fromJson(Map<String, dynamic> json) {
    final lista = JsonUtils.requireListaDeMapas(json, 'servicos_oferecidos');
    return ListarServicosOferecidosResponse(
      servicos: lista.map(ServicoOferecidoPreview.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servicos_oferecidos': servicos.map((s) => s.toJson()).toList(),
  };
}
