import 'package:shared/src/models/verificacao/verificacao_com_detalhes.dart';

class VerificacaoComUrls {
  final VerificacaoComDetalhes verificacao;
  final List<String> urlsArquivos;

  VerificacaoComUrls({required this.verificacao, required this.urlsArquivos});

  factory VerificacaoComUrls.fromJson(Map<String, dynamic> json) {
    return VerificacaoComUrls(
      verificacao: VerificacaoComDetalhes.fromJson(json),
      urlsArquivos: (json['urls_arquivos'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    ...verificacao.toJson(),
    'urls_arquivos': urlsArquivos,
  };
}
