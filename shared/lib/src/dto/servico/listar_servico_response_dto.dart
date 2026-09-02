import 'package:shared/shared.dart';

class ListarServicoResponse implements WsMessage {
  final List<Servico> servicos;
  ListarServicoResponse({required this.servicos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicosOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servicos': servicos.map((c) => c.toJson()).toList(),
  };
}
