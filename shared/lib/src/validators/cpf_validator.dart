class CpfValidator {
  static String limpar(String cpf) => cpf.replaceAll(RegExp(r'\D'), '');

  static bool isValido(String cpfBruto) {
    final cpf = limpar(cpfBruto);

    if (cpf.length != 11) return false;

    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

    final digitos = cpf.split('').map(int.parse).toList();

    final primeiroDigito = _calcularDigito(digitos.sublist(0, 9), 10);
    if (primeiroDigito != digitos[9]) return false;

    final segundoDigito = _calcularDigito(digitos.sublist(0, 10), 11);
    if (segundoDigito != digitos[10]) return false;

    return true;
  }

  static int _calcularDigito(List<int> base, int pesoInicial) {
    var soma = 0;
    var peso = pesoInicial;
    for (final digito in base) {
      soma += digito * peso;
      peso--;
    }
    final resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }
}
