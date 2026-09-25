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

class ContestacaoComUrls {
  final ContestacaoComDetalhes contestacao;
  final List<String> urlsArquivos;

  ContestacaoComUrls({required this.contestacao, required this.urlsArquivos});

  Map<String, dynamic> toJson() => {
    ...contestacao.toJson(),
    'urls_arquivos': urlsArquivos,
  };

  factory ContestacaoComUrls.fromJson(Map<String, dynamic> json) {
    return ContestacaoComUrls(
      contestacao: ContestacaoComDetalhes.fromJson(json),
      urlsArquivos: (json['urls_arquivos'] as List).cast<String>(),
    );
  }
}

class ListarMinhasContestacoesResponseDto implements WsMessage {
  final List<ContestacaoComUrls> contestacoes;

  ListarMinhasContestacoesResponseDto({required this.contestacoes});

  @override
  TipoMensagem get tipo => TipoMensagem.listarMinhasContestacoesOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'contestacoes': contestacoes.map((c) => c.toJson()).toList(),
  };
}
