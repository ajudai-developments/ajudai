import 'package:shared/shared.dart';

class ListarMinhasVerificacoesRequestDto implements WsMessage {
  const ListarMinhasVerificacoesRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.listarMinhasVerificacoes;

  factory ListarMinhasVerificacoesRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return const ListarMinhasVerificacoesRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class ListarMinhasVerificacoesResponseDto implements WsMessage {
  final List<VerificacaoComUrls> verificacoes;

  ListarMinhasVerificacoesResponseDto({required this.verificacoes});

  @override
  TipoMensagem get tipo => TipoMensagem.listarMinhasVerificacoesOk;

  factory ListarMinhasVerificacoesResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final lista = JsonUtils.requireListaDeMapas(json, 'verificacoes');
    return ListarMinhasVerificacoesResponseDto(
      verificacoes: lista.map(VerificacaoComUrls.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'verificacoes': verificacoes.map((v) => v.toJson()).toList(),
  };
}
