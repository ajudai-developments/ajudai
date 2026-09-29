import 'package:shared/shared.dart';

class ListarMinhasContestacoesRequestDto implements WsMessage {
  const ListarMinhasContestacoesRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.listarMinhasContestacoes;

  factory ListarMinhasContestacoesRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarMinhasContestacoesRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

class ListarMinhasContestacoesResponseDto implements WsMessage {
  final List<ContestacaoComUrls> contestacoes;

  ListarMinhasContestacoesResponseDto({required this.contestacoes});

  @override
  TipoMensagem get tipo => TipoMensagem.listarMinhasContestacoesOk;

  factory ListarMinhasContestacoesResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final lista = JsonUtils.requireListaDeMapas(json, 'contestacoes');
    return ListarMinhasContestacoesResponseDto(
      contestacoes: lista.map(ContestacaoComUrls.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'contestacoes': contestacoes.map((c) => c.toJson()).toList(),
  };
}
