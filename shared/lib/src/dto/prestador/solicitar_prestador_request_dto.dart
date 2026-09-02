import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

/// O usuário autenticado pede para virar prestador. Não precisa de nenhum
/// campo — o backend usa o id da sessão e cria uma linha em `verificacoes`
/// + muda `usuarios.status_prestador` para `pendente`.
class SolicitarPrestadorRequestDto implements WsMessage {
  SolicitarPrestadorRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.solicitarPrestador;

  factory SolicitarPrestadorRequestDto.fromJson(Map<String, dynamic> json) {
    return SolicitarPrestadorRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}
