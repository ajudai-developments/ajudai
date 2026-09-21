import 'package:shared/shared.dart';

class EnviarMensagemRequestDto implements WsMessage {
  final String idConversa;
  final String texto;

  EnviarMensagemRequestDto({required this.idConversa, required this.texto});

  factory EnviarMensagemRequestDto.fromJson(Map<String, dynamic> json) {
    return EnviarMensagemRequestDto(
      idConversa: JsonUtils.requireString(json, 'id_conversa'),
      texto: JsonUtils.requireString(json, 'texto'),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.enviarMensagem;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'id_conversa': idConversa,
    'texto': texto,
  };
}

class EnviarMensagemResponseDto implements WsMessage {
  final Mensagem mensagem;

  EnviarMensagemResponseDto({required this.mensagem});

  @override
  TipoMensagem get tipo => TipoMensagem.enviarMensagemOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'mensagem': mensagem.toJson(),
  };
}

class NovaMensagemDto implements WsMessage {
  final Mensagem mensagem;

  NovaMensagemDto({required this.mensagem});

  @override
  TipoMensagem get tipo => TipoMensagem.novaMensagem;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'mensagem': mensagem.toJson(),
  };
}
