import 'package:shared/shared.dart';

class ListarMensagensRequestDto implements WsMessage {
  final String idConversa;
  final DateTime? antesDe;
  final int limite;

  ListarMensagensRequestDto({
    required this.idConversa,
    this.antesDe,
    this.limite = 50,
  });

  factory ListarMensagensRequestDto.fromJson(Map<String, dynamic> json) {
    return ListarMensagensRequestDto(
      idConversa: JsonUtils.requireString(json, 'id_conversa'),
      antesDe: JsonUtils.optionalDateTime(json, 'antes_de'),
      limite: JsonUtils.optionalInt(json, 'limite') ?? 50,
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.listarMensagens;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'id_conversa': idConversa,
    if (antesDe != null) 'antes_de': antesDe!.toIso8601String(),
    'limite': limite,
  };
}

class ListarMensagensResponseDto implements WsMessage {
  final List<MensagemComUrl> mensagens;

  ListarMensagensResponseDto({required this.mensagens});

  @override
  TipoMensagem get tipo => TipoMensagem.listarMensagensOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'mensagens': mensagens.map((m) => m.toJson()).toList(),
  };
}
