import 'package:shared/shared.dart';

class AdminResponderContestacaoRequestDto implements WsMessage {
  final String contestacaoId;
  final StatusContestacao status;
  final String resposta;
  final StatusAgendamento statusAgendamentoFinal;

  AdminResponderContestacaoRequestDto({
    required this.contestacaoId,
    required this.status,
    required this.resposta,
    required this.statusAgendamentoFinal,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.adminResponderContestacao;

  factory AdminResponderContestacaoRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminResponderContestacaoRequestDto(
      contestacaoId: JsonUtils.requireString(json, 'contestacao_id'),
      status: StatusContestacao.fromValor(
        JsonUtils.requireString(json, 'status'),
      ),
      resposta: JsonUtils.requireString(json, 'resposta'),
      statusAgendamentoFinal: StatusAgendamento.fromValor(
        JsonUtils.requireString(json, 'status_agendamento_final'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'contestacao_id': contestacaoId,
    'status': status.valor,
    'resposta': resposta,
    'status_agendamento_final': statusAgendamentoFinal.valor,
  };
}

class AdminResponderContestacaoResponseDto implements WsMessage {
  final Contestacao contestacao;

  AdminResponderContestacaoResponseDto({required this.contestacao});

  @override
  TipoMensagem get tipo => TipoMensagem.adminResponderContestacaoOk;

  factory AdminResponderContestacaoResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminResponderContestacaoResponseDto(
      contestacao: Contestacao.fromJson(
        json['contestacao'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'contestacao': contestacao.toJson(),
  };
}
