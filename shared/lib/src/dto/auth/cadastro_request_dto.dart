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
      email: json['email'] as String,
      senha: json['senha'] as String,
      nome: json['nome'] as String,
      cpf: json['cpf'] as String,
      telefone: json['telefone'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo,
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
