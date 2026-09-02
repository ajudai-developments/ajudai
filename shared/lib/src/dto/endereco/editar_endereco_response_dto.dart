import 'package:shared/shared.dart';

class EditarEnderecoResponseDto implements WsMessage {
  final Endereco endereco;

  const EditarEnderecoResponseDto({required this.endereco});

  @override
  TipoMensagem get tipo => TipoMensagem.criarEnderecoOk;

  factory EditarEnderecoResponseDto.fromJson(Map<String, dynamic> json) {
    return EditarEnderecoResponseDto(endereco: Endereco.fromJson(json));
  }

  @override
  Map<String, dynamic> toJson() => {
    "tipo": tipo.valor,
    "endereco": endereco.toJson(),
  };
}
