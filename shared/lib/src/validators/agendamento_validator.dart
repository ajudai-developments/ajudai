/// Regras de negócio para criação de agendamento. Usado tanto no backend
/// (obrigatório, fonte da verdade) quanto opcionalmente no app (feedback
/// imediato pro usuário antes de mandar pro servidor).
class AgendamentoValidator {
  static const antecedenciaMinima = Duration(minutes: 90);
  static const duracaoMinima = Duration(minutes: 30);
  static const limiteFuturo = Duration(days: 30);
  static const horaMinima = 6; // 06:00
  static const horaMaxima = 23; // 23:00 (fim do expediente)

  /// Lança [FormatException] com uma mensagem amigável se algo estiver
  /// fora das regras. Se não lançar, o horário é válido.
  static void validar({
    required DateTime horaInicio,
    required DateTime horaFim,
    DateTime? agora,
  }) {
    final referencia = agora ?? DateTime.now();

    if (!horaFim.isAfter(horaInicio)) {
      throw const FormatException(
        'O horário de término deve ser depois do horário de início.',
      );
    }

    if (horaInicio.isBefore(referencia.add(antecedenciaMinima))) {
      throw FormatException(
        'O agendamento precisa ser feito com pelo menos '
        '${antecedenciaMinima.inMinutes} minutos de antecedência.',
      );
    }

    if (horaInicio.isAfter(referencia.add(limiteFuturo))) {
      throw FormatException(
        'Não é possível agendar com mais de ${limiteFuturo.inDays} dias '
        'de antecedência.',
      );
    }

    final duracao = horaFim.difference(horaInicio);
    if (duracao < duracaoMinima) {
      throw FormatException(
        'O agendamento precisa durar pelo menos '
        '${duracaoMinima.inMinutes} minutos.',
      );
    }

    if (!_dentroDoHorarioPermitido(horaInicio) ||
        !_dentroDoHorarioPermitido(horaFim)) {
      throw FormatException(
        'Só é possível agendar entre ${horaMinima}h e ${horaMaxima}h.',
      );
    }
  }

  static bool _dentroDoHorarioPermitido(DateTime momento) {
    final minutosDoDia = momento.hour * 60 + momento.minute;
    final minimoEmMinutos = horaMinima * 60;
    final maximoEmMinutos = horaMaxima * 60;
    return minutosDoDia >= minimoEmMinutos && minutosDoDia <= maximoEmMinutos;
  }

  /// true/false sem lançar exceção — útil para validação silenciosa na UI.
  static bool ehValido({required DateTime horaInicio, required DateTime horaFim, DateTime? agora}) {
    try {
      validar(horaInicio: horaInicio, horaFim: horaFim, agora: agora);
      return true;
    } on FormatException {
      return false;
    }
  }
}
