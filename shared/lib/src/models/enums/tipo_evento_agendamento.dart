enum TipoEventoAgendamento {
  alertaAtraso('alerta_atraso'),
  canceladoPorAtraso('cancelado_por_atraso'),
  denunciaAtrasoReincidencia('denuncia_atraso_reincidencia'),
  naoConcluido('nao_concluido'),
  confirmacaoAutomatica('confirmacao_automatica');

  final String valor;
  const TipoEventoAgendamento(this.valor);

  static TipoEventoAgendamento fromValor(String valor) {
    return TipoEventoAgendamento.values.firstWhere(
      (e) => e.valor == valor,
      orElse: () =>
          throw FormatException('tipo_evento_agendamento inválido: "$valor"'),
    );
  }
}
