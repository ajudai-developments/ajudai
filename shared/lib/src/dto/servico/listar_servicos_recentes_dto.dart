import 'package:shared/shared.dart';

class ListarServicosRecentesRequestDto implements WsMessage {
  final int? limite;

  const ListarServicosRecentesRequestDto({this.limite});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicosRecente;

  factory ListarServicosRecentesRequestDto.fromJson(Map<String, dynamic> json) {
    return ListarServicosRecentesRequestDto(limite: json['limite'] as int?);
  }
  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    if (limite != null) 'limite': limite,
  };
}

class ListarServicosRecentesResponseDto implements WsMessage {
  final List<ServicoRecente> servicos;

  const ListarServicosRecentesResponseDto({required this.servicos});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicosRecenteOk;

  factory ListarServicosRecentesResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final lista = (json['servicos'] as List<dynamic>? ?? const []);
    return ListarServicosRecentesResponseDto(
      servicos: lista
          .map((e) => ServicoRecente.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servicos': servicos.map((s) => s.toJson()).toList(),
  };
}
