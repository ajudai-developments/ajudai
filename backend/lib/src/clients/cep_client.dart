import 'dart:convert';
import 'package:http/http.dart' as http;

class DadosCep {
  final String logradouro;
  final String bairro;
  final String cidade;
  final String estado;

  DadosCep({
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });
}

class CepClient {
  Future<DadosCep?> buscarPorCep(String cepLimpo) async {
    final response = await http.get(
      Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'),
    );

    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['erro'] == true) return null;

    return DadosCep(
      logradouro: json['logradouro'] as String,
      bairro: json['bairro'] as String,
      cidade: json['localidade'] as String,
      estado: json['uf'] as String,
    );
  }
}
