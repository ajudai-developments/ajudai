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
