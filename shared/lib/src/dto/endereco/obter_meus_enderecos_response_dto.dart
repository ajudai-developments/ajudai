import 'package:shared/shared.dart';

class ObterMeusEnderecosResponseDto implements WsMessage {
  final List<Endereco> enderecos;

  ObterMeusEnderecosResponseDto({required this.enderecos});

  @override
  TipoMensagem get tipo => TipoMensagem.obterMeusEnderecosOk;

  factory ObterMeusEnderecosResponseDto.fromJson(Map<String, dynamic> json) {
    return ObterMeusEnderecosResponseDto(
      enderecos: (json['enderecos'] as List)
          .map((e) => Endereco.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'enderecos': enderecos.map((e) => e.toJson()).toList(),
  };
}
