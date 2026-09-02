class ServicoOferecido {
  final String id;
  final String servicoId;
  final String usuarioId;
  final String descricao;
  final double valor;

  ServicoOferecido({
    required this.id,
    required this.servicoId,
    required this.usuarioId,
    required this.descricao,
    required this.valor,
  });

  factory ServicoOferecido.fromJson(Map<String, dynamic> json) =>
      ServicoOferecido(
        id: json['id'] as String,
        servicoId: json['servico_id'] as String,
        usuarioId: json['usuario_id'] as String,
        descricao: json['descricao'] as String,
        valor: (json['valor'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'servico_id': servicoId,
    'usuario_id': usuarioId,
    'descricao': descricao,
    'valor': valor,
  };
}
