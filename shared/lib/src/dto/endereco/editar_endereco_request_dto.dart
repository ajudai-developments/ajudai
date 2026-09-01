import 'package:shared/shared.dart';

class EditarEnderecoRequestDto implements WsMessage {
  final String enderecoId;
  final String cep;
  final String numero;
  final String nome;
  final String? complemento;

  const EditarEnderecoRequestDto({
    required this.enderecoId,
    required this.cep,
    required this.numero,
    required this.nome,
    required this.complemento,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.editarEndereco;

  factory EditarEnderecoRequestDto.fromJson(Map<String, dynamic> json) {
    return EditarEnderecoRequestDto(
      enderecoId: JsonUtils.requireString(json, 'endereco_id'),
      cep: JsonUtils.requireString(json, 'cep'),
      numero: JsonUtils.requireString(json, 'numero'),
      nome: JsonUtils.requireString(json, 'nome'),
      complemento: JsonUtils.optionalString(json, 'complemento'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "tipo": tipo.valor,
      "endereco_id": enderecoId,
      "cep": cep,
      "numero": numero,
      "nome": nome,
      "complemento": complemento,
    };
  }
}
