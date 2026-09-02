import 'package:shared/shared.dart';

class ListarCategoriasResponseDto implements WsMessage {
  final List<Categoria> categorias;

  ListarCategoriasResponseDto({required this.categorias});

  @override
  TipoMensagem get tipo => TipoMensagem.listarCategoriasOk;

  factory ListarCategoriasResponseDto.fromJson(Map<String, dynamic> json) {
    final lista = JsonUtils.requireListaDeMapas(json, 'categorias');
    return ListarCategoriasResponseDto(
      categorias: lista.map(Categoria.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'categorias': categorias.map((c) => c.toJson()).toList(),
  };
}
