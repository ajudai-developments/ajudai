enum StatusDenuncia {
  aberta,
  emAnalise,
  resolvida,
  rejeitada;

  String get valor {
    switch (this) {
      case StatusDenuncia.aberta:
        return 'aberta';
      case StatusDenuncia.emAnalise:
        return 'em_analise';
      case StatusDenuncia.resolvida:
        return 'resolvida';
      case StatusDenuncia.rejeitada:
        return 'rejeitada';
    }
  }

  static StatusDenuncia fromValor(String valor) {
    return StatusDenuncia.values.firstWhere(
      (e) => e.valor == valor,
      orElse: () => throw FormatException('status_denuncia inválido: "$valor"'),
    );
  }

  @override
  String toString() => valor;
}
