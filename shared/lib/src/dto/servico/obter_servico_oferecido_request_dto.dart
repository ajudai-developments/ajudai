import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class ObterServicoOferecidoRequestDto implements WsMessage {
  final String servicoOferecidoId;

  ObterServicoOferecidoRequestDto({required this.servicoOferecidoId});

  @override
  TipoMensagem get tipo => TipoMensagem.obterServicoOferecido;

  factory ObterServicoOferecidoRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ObterServicoOferecidoRequestDto(
      servicoOferecidoId: JsonUtils.requireString(
        json,
        'servico_oferecido_id',
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_oferecido_id': servicoOferecidoId,
  };
}
