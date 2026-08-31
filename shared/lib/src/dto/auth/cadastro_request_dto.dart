import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';

import '../ws_message.dart';

class CadastroRequestDto implements WsMessage {
  final String email;
  final String senha;
  final String nome;
  final String cpf;
  final String? telefone;

  CadastroRequestDto({
    required this.email,
    required this.senha,
    required this.nome,
    required this.cpf,
    required this.telefone,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.cadastro;

  factory CadastroRequestDto.fromJson(Map<String, dynamic> json) {
    return CadastroRequestDto(
      email: JsonUtils.requireString(json, "email"),
      senha: JsonUtils.requireString(json, "senha"),
      nome: JsonUtils.requireString(json, "nome"),
      cpf: JsonUtils.requireString(json, "cpf"),
      telefone: JsonUtils.optionalString(json, "telefone"),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'email': email,
    'senha': senha,
    'nome': nome,
    'cpf': cpf,
    'telefone': telefone,
  };

  Map<String, dynamic> toSupabaseMetadata() => {
    'nome': nome,
    'cpf': cpf,
    'telefone': telefone,
  };
}
