enum EventosAgendamentos {
  alertaAtraso('alerta_atraso'),
  alertaInicio('alerta_inicio'),
  denunciaAtraso('denuncia_atraso'),
  alertaFinalizacao('alerta_finalizacao'),
  naoConcluido('nao_concluido'),
  confirmacaoAutomatica('confirmacao_automatica'),
  canceladoPorAtraso('cancelado_por_atraso');

  final String valor;
  const EventosAgendamentos(this.valor);

  static EventosAgendamentos? fromValor(String valor) {
    for (final e in EventosAgendamentos.values) {
      if (e.valor == valor) return e;
    }
    return null;
  }
}
