import 'package:shared/shared.dart';

class CriarServicoOferecidoResponseDto implements WsMessage {
  final ServicoOferecido servicoOferecido;

  CriarServicoOferecidoResponseDto({required this.servicoOferecido});

  @override
  TipoMensagem get tipo => TipoMensagem.criarServicoOferecidoOk;

  factory CriarServicoOferecidoResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return CriarServicoOferecidoResponseDto(
      servicoOferecido: ServicoOferecido.fromJson(
        json['servico_oferecido'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_oferecido': servicoOferecido.toJson(),
  };
}
