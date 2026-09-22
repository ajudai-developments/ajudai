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

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'denuncias': denuncias.map((d) => d.toJson()).toList(),
  };
}
