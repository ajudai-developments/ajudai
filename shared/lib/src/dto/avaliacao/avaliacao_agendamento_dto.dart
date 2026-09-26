import 'package:shared/shared.dart';

class AvaliarAgendamentoRequestDto implements WsMessage {
  final String agendamentoId;
  final double? avaliacao;
  final bool pulado;
  final String? descricao;
  final String? mensagem;
  final TipoDenuncia? tipoDenuncia;

  AvaliarAgendamentoRequestDto({
    required this.agendamentoId,
    this.avaliacao,
    this.pulado = false,
    this.descricao,
    this.mensagem,
    this.tipoDenuncia,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.avaliarAgendamento;

  factory AvaliarAgendamentoRequestDto.fromJson(Map<String, dynamic> json) {
    final tipoDenunciaValor = JsonUtils.optionalString(json, 'tipo_denuncia');
    return AvaliarAgendamentoRequestDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
      avaliacao: JsonUtils.optionalDouble(json, 'avaliacao'),
      pulado: JsonUtils.optionalBool(json, 'pulado'),
      descricao: JsonUtils.optionalString(json, 'descricao'),
      mensagem: JsonUtils.optionalString(json, 'mensagem'),
      tipoDenuncia: tipoDenunciaValor == null
          ? null
          : TipoDenuncia.fromValor(tipoDenunciaValor),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
    'avaliacao': avaliacao,
    'pulado': pulado,
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
