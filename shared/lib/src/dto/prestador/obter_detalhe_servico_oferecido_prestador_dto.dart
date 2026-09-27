import 'package:shared/shared.dart';

class ObterDetalheServicoOferecidoPrestadorRequestDto implements WsMessage {
  final String servicoOferecidoId;

  ObterDetalheServicoOferecidoPrestadorRequestDto({
    required this.servicoOferecidoId,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.obterDetalheServicoOferecidoPrestador;

  factory ObterDetalheServicoOferecidoPrestadorRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ObterDetalheServicoOferecidoPrestadorRequestDto(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
    );
  }

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
