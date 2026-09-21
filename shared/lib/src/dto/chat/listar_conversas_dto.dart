import 'package:shared/shared.dart';

class ListarConversasRequestDto implements WsMessage {
  ListarConversasRequestDto();

  factory ListarConversasRequestDto.fromJson(Map<String, dynamic> json) =>
      ListarConversasRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.listarConversas;

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class ListarConversasResponseDto implements WsMessage {
  final List<ConversaResumo> conversas;

  ListarConversasResponseDto({required this.conversas});

  @override
  TipoMensagem get tipo => TipoMensagem.listarConversasOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'conversas': conversas.map((c) => c.toJson()).toList(),
  };
}
