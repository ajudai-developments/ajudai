import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class CriarAgendamentoResponseDto implements WsMessage {
  final String servicoOferecidoId;
  final String nomeServico;
  final String nomePrestador;
  final double valor;
  final DateTime horaInicio;
  final DateTime horaFim;
  final String enderecoResumo;

  CriarAgendamentoResponseDto({
    required this.servicoOferecidoId,
    required this.nomeServico,
    required this.nomePrestador,
    required this.valor,
    required this.horaInicio,
    required this.horaFim,
    required this.enderecoResumo,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.criarAgendamentoOk;

  factory CriarAgendamentoResponseDto.fromJson(Map<String, dynamic> json) {
    return CriarAgendamentoResponseDto(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
      nomeServico: JsonUtils.requireString(json, 'nome_servico'),
      nomePrestador: JsonUtils.requireString(json, 'nome_prestador'),
      valor: JsonUtils.requireDouble(json, 'valor'),
      horaInicio: JsonUtils.requireDateTime(json, 'hora_inicio'),
      horaFim: JsonUtils.requireDateTime(json, 'hora_fim'),
      enderecoResumo: JsonUtils.requireString(json, 'endereco_resumo'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_oferecido_id': servicoOferecidoId,
    'nome_servico': nomeServico,
    'nome_prestador': nomePrestador,
    'valor': valor,
    'hora_inicio': horaInicio.toIso8601String(),
    'hora_fim': horaFim.toIso8601String(),
    'endereco_resumo': enderecoResumo,
  };
}
