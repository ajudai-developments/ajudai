import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

/// Enviado por um admin autenticado para aprovar uma solicitação pendente.
/// O handler deve checar `usuario_role == admin` antes de processar.
class AprovarPrestadorRequestDto implements WsMessage {
  final String verificacaoId;

  AprovarPrestadorRequestDto({required this.verificacaoId});

  @override
  TipoMensagem get tipo => TipoMensagem.aprovarPrestador;

  factory AprovarPrestadorRequestDto.fromJson(Map<String, dynamic> json) {
    return AprovarPrestadorRequestDto(
      verificacaoId: JsonUtils.requireString(json, 'verificacao_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'verificacao_id': verificacaoId,
  };
}
