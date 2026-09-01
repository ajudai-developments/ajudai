import 'dart:convert';

import 'package:http/http.dart' as http;

class CepClient {
  static Future<Map<String, dynamic>?> buscarCep(String cepLimpo) async {
    final response = await http.get(
      Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'),
    );

    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json["erro"] == true) return null;

    return json;
  }
}
