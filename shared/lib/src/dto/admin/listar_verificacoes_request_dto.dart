import 'package:shared/shared.dart';

class ListarVerificacoesRequestDto implements WsMessage {
  final StatusVerificacao? status;

  ListarVerificacoesRequestDto({this.status});

  @override
  TipoMensagem get tipo => TipoMensagem.listarVerificacoes;

  factory ListarVerificacoesRequestDto.fromJson(Map<String, dynamic> json) {
    final valor = JsonUtils.optionalString(json, 'status');
    return ListarVerificacoesRequestDto(
      status: valor == null ? null : StatusVerificacao.fromString(valor),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, 'status': status?.name};
}
