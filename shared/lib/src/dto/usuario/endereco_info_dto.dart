class EnderecoInfoDto {
  final String cep;
  final String logradouro;
  final String bairro;
  final String cidade;
  final String estado;

  const EnderecoInfoDto({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });

  factory EnderecoInfoDto.fromJson(Map<String, dynamic> json) =>
      EnderecoInfoDto(
        cep: json["cep"],
        logradouro: json["logradouro"],
        bairro: json["bairro"],
        cidade: json["localidade"],
        estado: json["estado"],
      );
}
