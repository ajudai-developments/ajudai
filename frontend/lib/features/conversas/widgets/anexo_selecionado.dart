enum TipoAnexo { imagem, video }

class AnexoSelecionado {
  final String nomeOriginal;
  final String extensao;
  final TipoAnexo tipo;
  final String caminho;

  const AnexoSelecionado({
    required this.nomeOriginal,
    required this.extensao,
    required this.tipo,
    required this.caminho,
  });
}
