class Usuario {
  final String id;
  final String nome;
  final String cpf;
  final String? telefone;

  Usuario({
    required this.id,
    required this.nome,
    required this.cpf,
    this.telefone,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nome: json['nome'] as String,
      cpf: json['cpf'] as String,
      telefone: json['telefone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'cpf': cpf,
    'telefone': telefone,
  };
}
