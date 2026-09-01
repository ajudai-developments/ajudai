import 'package:shared/shared.dart';

class ObterMeusEnderecosResponseDto implements WsMessage {
  final List<Endereco> enderecos;

  ObterMeusEnderecosResponseDto({required this.enderecos});

  @override
  TipoMensagem get tipo => TipoMensagem.obterMeusEnderecosOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'enderecos': enderecos.map((e) => e.toJson()).toList(),
  };
}
