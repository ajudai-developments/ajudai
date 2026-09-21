enum TipoConteudoMensagem {
  texto('texto'),
  imagem('imagem'),
  audio('audio'),
  video('video');

  final String valor;
  const TipoConteudoMensagem(this.valor);

  static TipoConteudoMensagem? fromValor(String? valor) {
    for (final tipo in TipoConteudoMensagem.values) {
      if (tipo.valor == valor) return tipo;
    }
    return null;
  }
}
