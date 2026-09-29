import 'package:shared/shared.dart';

class AdminMarcarContestacaoEmAnaliseRequestDto implements WsMessage {
  final String contestacaoId;
  AdminMarcarContestacaoEmAnaliseRequestDto({required this.contestacaoId});

  @override
  TipoMensagem get tipo => TipoMensagem.adminMarcarContestacaoEmAnalise;

  factory AdminMarcarContestacaoEmAnaliseRequestDto.fromJson(
    Map<String, dynamic> json,
  ) => AdminMarcarContestacaoEmAnaliseRequestDto(
    contestacaoId: JsonUtils.requireString(json, 'contestacao_id'),
  );

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'contestacao_id': contestacaoId,
  };
}

class AdminMarcarContestacaoEmAnaliseResponseDto implements WsMessage {
  final String contestacaoId;
  final StatusContestacao status;

  AdminMarcarContestacaoEmAnaliseResponseDto({
    required this.contestacaoId,
    required this.status,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.adminMarcarContestacaoEmAnaliseOk;

  factory AdminMarcarContestacaoEmAnaliseResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminMarcarContestacaoEmAnaliseResponseDto(
      contestacaoId: JsonUtils.requireString(json, 'contestacao_id'),
      status: StatusContestacao.fromValor(
        JsonUtils.requireString(json, 'status'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'contestacao_id': contestacaoId,
    'status': status.valor,
  };
}
