import 'package:shared/shared.dart';

class CriarServicoOferecidoResponseDto implements WsMessage {
  final ServicoOferecido servicoOferecido;
  CriarServicoOferecidoResponseDto({required this.servicoOferecido});

  @override
  TipoMensagem get tipo => TipoMensagem.listarServicosOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_oferecido': servicoOferecido.toJson(),
  };
}
