import 'package:shared/shared.dart';

class ConsultarCepRequestDto implements WsMessage {
  final String cep;

  ConsultarCepRequestDto({required this.cep});

  @override
  TipoMensagem get tipo => TipoMensagem.consultarCep;

  factory ConsultarCepRequestDto.fromJson(Map<String, dynamic> json) {
    return ConsultarCepRequestDto(cep: JsonUtils.requireString(json, 'cep'));
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, 'cep': cep};
}
