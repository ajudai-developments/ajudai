class AgendamentoValidator {
  static const _antecedenciaMinima = Duration(hours: 1, minutes: 30);
  static const _antecedenciaMaxima = Duration(days: 30);
  static const _duracaoMinima = Duration(minutes: 30);
  static const _duracaoMaxima = Duration(hours: 6);
  static const _offsetBrasil = Duration(hours: -3);
  static const _horaMinimaPermitida = 6;
  static const _horaMaximaPermitida = 23;

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
    if (duracao > _duracaoMaxima) {
      throw ArgumentError(
        'Agendamento não pode durar mais que ${_duracaoMaxima.inHours} horas',
      );
    }

    final inicioLocal = horaInicioUtc.add(_offsetBrasil);
    final fimLocal = horaFimUtc.add(_offsetBrasil);

    final mesmoDia =
        inicioLocal.year == fimLocal.year &&
        inicioLocal.month == fimLocal.month &&
        inicioLocal.day == fimLocal.day;
    if (!mesmoDia) {
      throw ArgumentError(
        'Agendamento não pode passar da meia-noite '
        '(início e fim precisam ser no mesmo dia)',
      );
    }

    final minutosInicio = inicioLocal.hour * 60 + inicioLocal.minute;
    final minutosFim = fimLocal.hour * 60 + fimLocal.minute;
    final minimoEmMinutos = _horaMinimaPermitida * 60;
    final maximoEmMinutos = _horaMaximaPermitida * 60;

    if (minutosInicio < minimoEmMinutos) {
      throw ArgumentError('Agendamento só pode começar a partir das 06:00');
    }
    if (minutosFim > maximoEmMinutos) {
      throw ArgumentError('Agendamento precisa terminar até às 23:00');
    }
  }
}
