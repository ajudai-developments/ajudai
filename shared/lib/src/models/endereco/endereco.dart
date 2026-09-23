class Endereco {
  final String id;
  final String usuarioId;
  final String nome;
  final String cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String estado;
  final DateTime criadoEm;
  final DateTime? editadoEm;

  Endereco({
    required this.id,
    required this.usuarioId,
    required this.nome,
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.criadoEm,
    required this.editadoEm,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      nome: json['nome'] as String,
      cep: json['cep'] as String,
      logradouro: json['logradouro'] as String,
      numero: json['numero'] as String,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String,
      cidade: json['cidade'] as String,
      estado: json['estado'] as String,
      criadoEm: DateTime.parse(json['criado_em'] as String),
      editadoEm: json["editado_em"] != null
          ? DateTime.tryParse(json['editado_em'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'nome': nome,
    'cep': cep,
    'logradouro': logradouro,
    'numero': numero,
    'complemento': complemento,
    'bairro': bairro,
    'cidade': cidade,
    'estado': estado,
    'criado_em': criadoEm.toIso8601String(),
    'editado_em': editadoEm?.toIso8601String(),
  };
}
