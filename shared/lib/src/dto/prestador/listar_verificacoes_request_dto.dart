import 'package:shared/shared.dart';

class ListarVerificacoesRequestDto implements WsMessage {
  final StatusVerificacao status;

  ListarVerificacoesRequestDto({required this.status});

  @override
  TipoMensagem get tipo => TipoMensagem.listarVerificacoes;

  factory ListarVerificacoesRequestDto.fromJson(Map<String, dynamic> json) {
    return ListarVerificacoesRequestDto(
      status: StatusVerificacao.fromString(
        JsonUtils.requireString(json, 'status'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, 'status': status.name};
}
