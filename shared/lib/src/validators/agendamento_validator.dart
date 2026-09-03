class AgendamentoValidator {
  static const _antecedenciaMinima = Duration(hours: 1, minutes: 30);
  static const _antecedenciaMaxima = Duration(days: 30);
  static const _duracaoMinima = Duration(minutes: 30);
  static const _offsetBrasil = Duration(hours: -3);

  static void validar({
    required DateTime agoraUtc,
    required DateTime horaInicioUtc,
    required DateTime horaFimUtc,
  }) {
    if (!agoraUtc.isUtc || !horaInicioUtc.isUtc || !horaFimUtc.isUtc) {
      throw ArgumentError('Horários devem ser enviados em UTC');
    }

    if (!horaFimUtc.isAfter(horaInicioUtc)) {
      throw ArgumentError('Hora de término deve ser depois da hora de início');
    }

    final antecedencia = horaInicioUtc.difference(agoraUtc);
    if (antecedencia < _antecedenciaMinima) {
      throw ArgumentError(
        'Agendamento precisa ser feito com pelo menos 1h30 de antecedência',
      );
    }
    if (antecedencia > _antecedenciaMaxima) {
      throw ArgumentError(
        'Agendamento não pode ser feito com mais de 30 dias de antecedência',
      );
    }

    final duracao = horaFimUtc.difference(horaInicioUtc);
    if (duracao < _duracaoMinima) {
      throw ArgumentError('Agendamento precisa durar pelo menos 30 minutos');
    }

    final inicioLocal = horaInicioUtc.add(_offsetBrasil);
    final fimLocal = horaFimUtc.add(_offsetBrasil);

    if (inicioLocal.hour < 6) {
      throw ArgumentError('Agendamento só pode começar a partir das 06:00');
    }
    if (fimLocal.hour > 23 || (fimLocal.hour == 23 && fimLocal.minute > 0)) {
      throw ArgumentError('Agendamento precisa terminar até às 23:00');
    }
  }
}
