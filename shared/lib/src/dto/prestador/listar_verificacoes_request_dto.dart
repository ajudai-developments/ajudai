import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class ListarVerificacoesRequestDto implements WsMessage {
  /// 'pendente' | 'aprovado' | 'rejeitado'. Null = todas.
  final String? status;

  ListarVerificacoesRequestDto({this.status});

  @override
  TipoMensagem get tipo => TipoMensagem.listarVerificacoes;

  factory ListarVerificacoesRequestDto.fromJson(Map<String, dynamic> json) {
    return ListarVerificacoesRequestDto(
      status: JsonUtils.optionalString(json, 'status'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, 'status': status};
}
