class Servico {
  final String id;
  final String nome;
  final String categoriaId;

  Servico({required this.id, required this.nome, required this.categoriaId});

  factory Servico.fromJson(Map<String, dynamic> json) => Servico(
    id: json['id'] as String,
    nome: json['nome'] as String,
    categoriaId: json['categoria_id'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'categoria_id': categoriaId,
  };
}
