enum StatusAgendamento {
  pendente,
  aceito,
  emAndamento,
  recusado,
  cancelado,
  aguardandoConfirmacao,
  concluido,
  contestado;

  String get valor {
    switch (this) {
      case StatusAgendamento.pendente:
        return 'pendente';
      case StatusAgendamento.aceito:
        return 'aceito';
      case StatusAgendamento.emAndamento:
        return 'em_andamento';
      case StatusAgendamento.recusado:
        return 'recusado';
      case StatusAgendamento.cancelado:
        return 'cancelado';
      case StatusAgendamento.aguardandoConfirmacao:
        return 'aguardando_confirmacao';
      case StatusAgendamento.concluido:
        return 'concluido';
      case StatusAgendamento.contestado:
        return 'contestado';
    }
  }

  static StatusAgendamento fromValor(String valor) {
    return StatusAgendamento.values.firstWhere(
      (e) => e.valor == valor,
      orElse: () =>
          throw FormatException('status_agendamento inválido: "$valor"'),
    );
  }

  @override
  String toString() => valor;
}
