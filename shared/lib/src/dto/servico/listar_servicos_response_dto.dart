import 'package:shared/shared.dart';

class ListarServicosResponseDto implements WsMessage {
  final List<Servico> servicos;

  ListarServicosResponseDto({required this.servicos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicosOk;

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
