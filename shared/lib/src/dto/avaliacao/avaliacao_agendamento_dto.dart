import 'package:shared/shared.dart';

class AvaliarAgendamentoRequestDto implements WsMessage {
  final String agendamentoId;
  final double avaliacao;
  final String? descricao;
  final String? mensagem;
  final TipoDenuncia? tipoDenuncia;

  AvaliarAgendamentoRequestDto({
    required this.agendamentoId,
    required this.avaliacao,
    this.descricao,
    this.mensagem,
    this.tipoDenuncia,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.avaliarAgendamento;

  factory AvaliarAgendamentoRequestDto.fromJson(Map<String, dynamic> json) {
    return AvaliarAgendamentoRequestDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
      avaliacao: JsonUtils.requireDouble(json, 'avaliacao'),
      descricao: JsonUtils.optionalString(json, 'descricao'),
      mensagem: JsonUtils.optionalString(json, 'mensagem'),
      tipoDenuncia: TipoDenuncia.fromValor(
        JsonUtils.optionalString(json, 'tipo_denuncia') ?? '',
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
    'avaliacao': avaliacao,
    'descricao': descricao,
    'mensagem': mensagem,
    'tipo_denuncia': tipoDenuncia?.valor,
  };
}

class AvaliarAgendamentoResponseDto implements WsMessage {
  @override
  TipoMensagem get tipo => TipoMensagem.avaliarAgendamentoOk;

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}
