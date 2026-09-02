import 'package:shared/shared.dart';

class ListarVerificacoesResponseDto implements WsMessage {
  final List<VerificacaoComUsuario> verificacoes;

  ListarVerificacoesResponseDto({required this.verificacoes});

  @override
  TipoMensagem get tipo => TipoMensagem.listarVerificacoesOk;

  factory ListarVerificacoesResponseDto.fromJson(Map<String, dynamic> json) {
    final lista = JsonUtils.requireListaDeMapas(json, 'verificacoes');
    return ListarVerificacoesResponseDto(
      verificacoes: lista.map(VerificacaoComUsuario.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'verificacoes': verificacoes.map((v) => v.toJson()).toList(),
  };
}
