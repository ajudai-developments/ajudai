enum StatusContestacao {
  aberta('aberta'),
  emAnalise('em_analise'),
  resolvida('resolvida'),
  rejeitada('rejeitada');

  final String valor;
  const StatusContestacao(this.valor);

  static StatusContestacao fromValor(String valor) {
    return StatusContestacao.values.firstWhere(
      (e) => e.valor == valor,
      orElse: () =>
          throw FormatException('status_contestacao inválido: "$valor"'),
    );
  }

  @override
  String toString() => valor;
}
