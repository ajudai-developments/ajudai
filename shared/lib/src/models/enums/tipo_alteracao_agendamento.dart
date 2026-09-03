enum TipoAlteracaoAgendamento {
  horario,
  endereco,
  preco,
  status;

  static TipoAlteracaoAgendamento fromString(String value) =>
      TipoAlteracaoAgendamento.values.firstWhere((e) => e.name == value);
}
