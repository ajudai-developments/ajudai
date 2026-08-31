class JsonUtils {
  static String requireString(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor is! String || valor.isEmpty) {
      throw FormatException('Campo "$campo" ausente ou inválido');
    }
    return valor;
  }

  static String? optionalString(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    return valor is String ? valor : null;
  }
}
