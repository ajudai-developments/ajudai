import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class ConfirmarPagamentoRequestDto implements WsMessage {
  final String servicoOferecidoId;
  final String enderecoId;
  final DateTime horaInicio;
  final DateTime horaFim;
  final double valor;

  final String metodoPagamento;

  ConfirmarPagamentoRequestDto({
    required this.servicoOferecidoId,
    required this.enderecoId,

    required this.horaInicio,
    required this.horaFim,
    required this.valor,
    required this.metodoPagamento,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.confirmarPagamento;

  factory ConfirmarPagamentoRequestDto.fromJson(Map<String, dynamic> json) {
    return ConfirmarPagamentoRequestDto(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
      enderecoId: JsonUtils.requireString(json, 'endereco_id'),

      horaInicio: JsonUtils.requireDateTime(json, 'hora_inicio'),
      horaFim: JsonUtils.requireDateTime(json, 'hora_fim'),
      valor: JsonUtils.requireDouble(json, 'valor'),
      metodoPagamento: JsonUtils.requireString(json, 'metodo_pagamento'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_oferecido_id': servicoOferecidoId,
    'endereco_id': enderecoId,

    'hora_inicio': horaInicio.toIso8601String(),
    'hora_fim': horaFim.toIso8601String(),
    'valor': valor,
    'metodo_pagamento': metodoPagamento,
  };
}
