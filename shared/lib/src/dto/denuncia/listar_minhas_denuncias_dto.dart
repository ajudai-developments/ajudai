import 'package:shared/shared.dart';

class ListarMinhasDenunciasRequestDto implements WsMessage {
  const ListarMinhasDenunciasRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.listarMinhasDenuncias;

  factory ListarMinhasDenunciasRequestDto.fromJson(Map<String, dynamic> json) {
    return ListarMinhasDenunciasRequestDto();
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}

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

class ListarMinhasDenunciasResponseDto implements WsMessage {
  final List<DenunciaComUrls> denuncias;

  ListarMinhasDenunciasResponseDto({required this.denuncias});

  @override
  TipoMensagem get tipo => TipoMensagem.listarMinhasDenunciasOk;

  factory ListarMinhasDenunciasResponseDto.fromJson(Map<String, dynamic> json) {
    final lista = JsonUtils.requireListaDeMapas(json, 'denuncias');
    return ListarMinhasDenunciasResponseDto(
      denuncias: lista.map(DenunciaComUrls.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'denuncias': denuncias.map((d) => d.toJson()).toList(),
  };
}
