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

  static double requireDouble(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor is num) return valor.toDouble();
    throw FormatException('Campo "$campo" ausente ou inválido');
  }

  static double? optionalDouble(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    return valor is num ? valor.toDouble() : null;
  }

  static int requireInt(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    throw FormatException('Campo "$campo" ausente ou inválido');
  }

  static int? optionalInt(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    return null;
  }

  static bool requireBool(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor is bool) return valor;
    throw FormatException('Campo "$campo" ausente ou inválido');
  }

  static bool optionalBool(
    Map<String, dynamic> json,
    String campo, {
    bool valorPadrao = false,
  }) {
    final valor = json[campo];
    return valor is bool ? valor : valorPadrao;
  }

  static DateTime requireDateTime(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor is String) {
      final data = DateTime.tryParse(valor);
      if (data != null) return data;
    }
    throw FormatException('Campo "$campo" ausente ou inválido');
  }

  static DateTime? optionalDateTime(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor is String) return DateTime.tryParse(valor);
    return null;
  }

  static List<Map<String, dynamic>> requireListaDeMapas(
    Map<String, dynamic> json,
    String campo,
  ) {
    final valor = json[campo];
    if (valor is List) {
      return valor.cast<Map<String, dynamic>>();
    }
    throw FormatException('Campo "$campo" ausente ou inválido');
  }
}
