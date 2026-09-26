enum EventosAgendamentos {
  alertaAtraso('alerta_atraso'),
  alertaInicio('alerta_inicio'),
  alertaFinalizacao('alerta_finalizacao'),
  naoConcluido('nao_concluido'),
  confirmacaoAutomatica('confirmacao_automatica');

  final String valor;
  const EventosAgendamentos(this.valor);

  static EventosAgendamentos? fromValor(String valor) {
    for (final e in EventosAgendamentos.values) {
      if (e.valor == valor) return e;
    }
    return null;
  }
}
