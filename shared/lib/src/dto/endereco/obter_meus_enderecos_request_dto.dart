import 'package:shared/shared.dart';

class ObterMeusEnderecosRequestDto implements WsMessage {
  @override
  TipoMensagem get tipo => TipoMensagem.obterMeusEnderecos;

  const ObterMeusEnderecosRequestDto();

  factory ObterMeusEnderecosRequestDto.fromJson(Map<String, dynamic> json) {
    return ObterMeusEnderecosRequestDto();
  }
  @override
  Map<String, dynamic> toJson() => {"tipo": tipo.valor};
}
