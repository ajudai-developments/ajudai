import 'package:shared/shared.dart';

class AdminListarContestacoesRequestDto implements WsMessage {
  final StatusContestacao? status;

  AdminListarContestacoesRequestDto({this.status});

  @override
  TipoMensagem get tipo => TipoMensagem.adminListarContestacoes;

  factory AdminListarContestacoesRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final valor = JsonUtils.optionalString(json, 'status');
    return AdminListarContestacoesRequestDto(
      status: valor == null ? null : StatusContestacao.fromValor(valor),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'status': status?.valor,
  };
}

class AdminListarContestacoesResponseDto implements WsMessage {
  final List<ContestacaoComDetalhes> contestacoes;

  AdminListarContestacoesResponseDto({required this.contestacoes});

  @override
  TipoMensagem get tipo => TipoMensagem.adminListarContestacoesOk;

  factory AdminListarContestacoesResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final lista = JsonUtils.requireListaDeMapas(json, 'contestacoes');
    return AdminListarContestacoesResponseDto(
      contestacoes: lista.map(ContestacaoComDetalhes.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'contestacoes': contestacoes.map((c) => c.toJson()).toList(),
  };
}
