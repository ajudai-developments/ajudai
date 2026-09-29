import 'package:shared/shared.dart';

class ContestacaoComUrls {
  final ContestacaoComDetalhes contestacao;
  final List<String?> urlsArquivos;

  ContestacaoComUrls({required this.contestacao, required this.urlsArquivos});

  Map<String, dynamic> toJson() => {
    ...contestacao.toJson(),
    'urls_arquivos': urlsArquivos,
  };

  factory ContestacaoComUrls.fromJson(Map<String, dynamic> json) {
    return ContestacaoComUrls(
      contestacao: ContestacaoComDetalhes.fromJson(json),
      urlsArquivos: (json['urls_arquivos'] as List)
          .map((e) => e as String?)
          .toList(),
    );
  }

  ContestacaoComUrls comStatus(StatusContestacao novo) => ContestacaoComUrls(
    contestacao: contestacao.comStatus(novo),
    urlsArquivos: urlsArquivos,
  );
}
