import '../tipo_mensagem.dart';
import '../ws_message.dart';
import '../../models/servico/servico_oferecido_detalhe_prestador.dart';

class ObterDetalheServicoOferecidoPrestadorRequestDto implements WsMessage {
  final String servicoOferecidoId;

  ObterDetalheServicoOferecidoPrestadorRequestDto({
    required this.servicoOferecidoId,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.obterDetalheServicoOferecidoPrestador;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_oferecido_id': servicoOferecidoId,
  };
}

class ObterDetalheServicoOferecidoPrestadorResponseDto implements WsMessage {
  final ServicoOferecidoDetalhePrestador detalhe;

  ObterDetalheServicoOferecidoPrestadorResponseDto({required this.detalhe});

  @override
  TipoMensagem get tipo => TipoMensagem.obterDetalheServicoOferecidoPrestadorOk;

  factory ObterDetalheServicoOferecidoPrestadorResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ObterDetalheServicoOferecidoPrestadorResponseDto(
      detalhe: ServicoOferecidoDetalhePrestador.fromJson(json),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, ...detalhe.toJson()};
}
