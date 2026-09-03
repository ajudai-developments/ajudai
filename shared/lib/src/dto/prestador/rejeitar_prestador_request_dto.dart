import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class RejeitarPrestadorRequestDto implements WsMessage {
  final String verificacaoId;

  RejeitarPrestadorRequestDto({required this.verificacaoId});

  @override
  TipoMensagem get tipo => TipoMensagem.rejeitarPrestador;

  factory RejeitarPrestadorRequestDto.fromJson(Map<String, dynamic> json) {
    return RejeitarPrestadorRequestDto(
      verificacaoId: JsonUtils.requireString(json, 'verificacao_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'verificacao_id': verificacaoId,
  };
}
