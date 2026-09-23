import 'package:shared/shared.dart';

class EnviarMensagemRequestDto implements WsMessage {
  final String idConversa;
  final String? texto;
  final ArquivoUpload? arquivo;

  EnviarMensagemRequestDto({
    required this.idConversa,
    this.texto,
    this.arquivo,
  });

  factory EnviarMensagemRequestDto.fromJson(Map<String, dynamic> json) {
    final arquivoJson = json['arquivo'] as Map<String, dynamic>?;
    return EnviarMensagemRequestDto(
      idConversa: JsonUtils.requireString(json, 'id_conversa'),
      texto: JsonUtils.optionalString(json, 'texto'),
      arquivo: arquivoJson != null ? ArquivoUpload.fromJson(arquivoJson) : null,
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.enviarMensagem;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'id_conversa': idConversa,
    'texto': texto,
    'arquivo': arquivo?.toJson(),
  };
}

class EnviarMensagemResponseDto implements WsMessage {
  final MensagemComUrl mensagem;

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
  final MensagemComUrl mensagem;

  NovaMensagemDto({required this.mensagem});

  @override
  TipoMensagem get tipo => TipoMensagem.novaMensagem;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'mensagem': mensagem.toJson(),
  };
}
