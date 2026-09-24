enum TipoArquivo {
  imagem('imagem'),
  audio('audio'),
  video('video'),
  documento('documento');

  final String valor;
  const TipoArquivo(this.valor);

  static TipoArquivo fromValor(String valor) {
    return TipoArquivo.values.firstWhere(
      (e) => e.valor == valor,
      orElse: () => throw FormatException('tipo_arquivo inválido: "$valor"'),
    );
  }
}
