enum StatusPrestador {
  naoSolicitado,
  pendente,
  aprovado,
  suspenso;

  static StatusPrestador fromString(String value) {
    final normalizado = value.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (m) => m.group(1)!.toUpperCase(),
    );
    return StatusPrestador.values.firstWhere((e) => e.name == normalizado);
  }

  String toDbValue() {
    return name.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => '_${m.group(0)!.toLowerCase()}',
    );
  }
}
