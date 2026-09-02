enum StatusVerificacao {
  pendente,
  aprovado,
  rejeitado;

  static StatusVerificacao fromString(String value) =>
      StatusVerificacao.values.firstWhere((e) => e.name == value);
}
