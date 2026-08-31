class TelefoneValidator {
  static String limpar(String telefone) =>
      telefone.replaceAll(RegExp(r'\D'), '');

  static bool isValido(String telefoneBruto) {
    final telefone = limpar(telefoneBruto);

    final semCodigoPais = telefone.startsWith('55') && telefone.length > 11
        ? telefone.substring(2)
        : telefone;

    if (semCodigoPais.length != 10 && semCodigoPais.length != 11) return false;

    final ddd = int.parse(semCodigoPais.substring(0, 2));
    if (ddd < 11 || ddd > 99) return false;

    if (semCodigoPais.length == 11 && semCodigoPais[2] != '9') return false;

    return true;
  }
}
