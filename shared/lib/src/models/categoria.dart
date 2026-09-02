class Categoria {
  final String id;
  final String nome;

  Categoria({required this.id, required this.nome});

  factory Categoria.fromJson(Map<String, dynamic> json) =>
      Categoria(id: json['id'] as String, nome: json['nome'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome};
}
