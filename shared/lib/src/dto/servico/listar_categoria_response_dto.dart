import 'package:shared/shared.dart';

class ListarCategoriasResponseDto implements WsMessage {
  final List<Categoria> categorias;
  ListarCategoriasResponseDto({required this.categorias});

  @override
  TipoMensagem get tipo => TipoMensagem.listarCategoriasOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'categorias': categorias.map((c) => c.toJson()).toList(),
  };
}
