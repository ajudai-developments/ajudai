import 'package:shared/shared.dart';

class CriarEnderecoRequestDto implements WsMessage {
  final String nome;
  final String cep;
  final String numero;
  final String? complemento;

  CriarEnderecoRequestDto({
    required this.nome,
    required this.cep,
    required this.numero,
    this.complemento,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.criarEndereco;

  factory CriarEnderecoRequestDto.fromJson(Map<String, dynamic> json) {
    return CriarEnderecoRequestDto(
      nome: JsonUtils.requireString(json, 'nome'),
      cep: JsonUtils.requireString(json, 'cep'),
      numero: JsonUtils.requireString(json, 'numero'),
      complemento: JsonUtils.optionalString(json, 'complemento'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'nome': nome,
    'cep': cep,
    'numero': numero,
    if (complemento != null) 'complemento': complemento,
  };
}
