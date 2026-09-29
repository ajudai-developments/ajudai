import 'package:shared/shared.dart';

class DenunciaComUrls {
  final Denuncia denuncia;
  final List<String> urlsArquivos;

  DenunciaComUrls({required this.denuncia, required this.urlsArquivos});

  factory DenunciaComUrls.fromJson(Map<String, dynamic> json) {
    return DenunciaComUrls(
      denuncia: Denuncia.fromJson(json),
      urlsArquivos: (json['urls_arquivos'] as List)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    ...denuncia.toJson(),
    'urls_arquivos': urlsArquivos,
  };
}
