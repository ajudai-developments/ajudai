import 'package:shared/shared.dart';

class CriarEnderecoResponseDto implements WsMessage {
  final Endereco endereco;

  const CriarEnderecoResponseDto({required this.endereco});

  @override
  TipoMensagem get tipo => TipoMensagem.criarEnderecoOk;

  factory CriarEnderecoResponseDto.fromJson(Map<String, dynamic> json) {
    return CriarEnderecoResponseDto(endereco: Endereco.fromJson(json));
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'endereco': endereco.toJson(),
  };
}
