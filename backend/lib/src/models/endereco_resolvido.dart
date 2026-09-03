class EnderecoResolvido {
  final String? id;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;

  EnderecoResolvido({
    this.id,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
  });

  String get resumo => '$logradouro, $numero - $bairro, $cidade/$estado';
}
