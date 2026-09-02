import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class RejeitarPrestadorRequestDto implements WsMessage {
  final String verificacaoId;
  final String? motivo;

  RejeitarPrestadorRequestDto({required this.verificacaoId, this.motivo});

  @override
  TipoMensagem get tipo => TipoMensagem.rejeitarPrestador;

  factory RejeitarPrestadorRequestDto.fromJson(Map<String, dynamic> json) {
    return RejeitarPrestadorRequestDto(
      verificacaoId: JsonUtils.requireString(json, 'verificacao_id'),
      motivo: JsonUtils.optionalString(json, 'motivo'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'verificacao_id': verificacaoId,
    'motivo': motivo,
  };
}
