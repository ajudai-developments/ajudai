enum CategoriaNotificacao {
  agendamento,
  conversa,
  geral;

  String get valor => switch (this) {
    CategoriaNotificacao.agendamento => 'agendamento',
    CategoriaNotificacao.conversa => 'conversa',
    CategoriaNotificacao.geral => 'geral',
  };

  static CategoriaNotificacao fromValor(String valor) {
    return CategoriaNotificacao.values.firstWhere(
      (e) => e.valor == valor,
      orElse: () => CategoriaNotificacao.geral,
    );
  }
}
