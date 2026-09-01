class SenhaValidator {
  static const tamanhoMinimo = 8;

  static bool isValida(String senha) {
    if (senha.length < tamanhoMinimo) return false;
    final temLetra = RegExp(r'[A-Za-z]').hasMatch(senha);
    final temNumero = RegExp(r'[0-9]').hasMatch(senha);
    return temLetra && temNumero;
  }

  /// Retorna a mensagem de erro ou `null` se a senha for válida.
  static String? mensagemErro(String? senha) {
    if (senha == null || senha.isEmpty) return 'Informe uma senha';
    if (senha.length < tamanhoMinimo) {
      return 'A senha deve ter ao menos $tamanhoMinimo caracteres';
    }
    if (!isValida(senha)) {
      return 'A senha deve conter letras e números';
    }
    return null;
  }
}
