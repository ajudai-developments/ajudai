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

  factory ListarConversasResponseDto.fromJson(Map<String, dynamic> json) {
    final itens = (json['conversas'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return ListarConversasResponseDto(
      conversas: itens.map(ConversaResumo.fromMap).toList(),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.listarConversasOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'conversas': conversas.map((c) => c.toJson()).toList(),
  };
}
