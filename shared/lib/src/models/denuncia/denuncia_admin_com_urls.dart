import 'package:shared/shared.dart';

class DenunciaAdminComUrls {
  final DenunciaComDetalhes denuncia;
  final List<String> urlsArquivos;

  DenunciaAdminComUrls({required this.denuncia, required this.urlsArquivos});

  factory DenunciaAdminComUrls.fromJson(Map<String, dynamic> json) {
    return DenunciaAdminComUrls(
      denuncia: DenunciaComDetalhes.fromJson(json),
      urlsArquivos: (json['urls_arquivos'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    ...denuncia.toJson(),
    'urls_arquivos': urlsArquivos,
  };

  DenunciaAdminComUrls comStatus(StatusDenuncia novo) => DenunciaAdminComUrls(
    denuncia: denuncia.comStatus(novo),
    urlsArquivos: urlsArquivos,
  );
}
