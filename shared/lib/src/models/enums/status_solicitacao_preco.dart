enum StatusSolicitacaoPreco {
  pendente('pendente'),
  aceita('aceita'),
  recusada('recusada');

  final String valor;
  const StatusSolicitacaoPreco(this.valor);

  static StatusSolicitacaoPreco fromValor(String valor) {
    return StatusSolicitacaoPreco.values.firstWhere(
      (e) => e.valor == valor,
      orElse: () =>
          throw FormatException('status_solicitacao_preco inválido: "$valor"'),
    );
  }

  @override
  String toString() => valor;
}
