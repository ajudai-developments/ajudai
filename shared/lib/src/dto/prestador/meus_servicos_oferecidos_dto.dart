import 'package:shared/shared.dart';

class ListarMeusServicosOferecidosRequestDto implements WsMessage {
  @override
  TipoMensagem get tipo => TipoMensagem.listarMeusServicosOferecidos;

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class ListarMeusServicosOferecidosResponseDto implements WsMessage {
  final List<ServicoOferecido> servicosOferecidos;
  ListarMeusServicosOferecidosResponseDto({required this.servicosOferecidos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarMeusServicosOferecidosOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servicos_oferecidos': servicosOferecidos.map((s) => s.toJson()).toList(),
  };
}
