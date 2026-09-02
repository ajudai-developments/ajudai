import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/enums/status_agendamento.dart';

class Agendamento {
  final String id;
  final String usuarioId;
  final String prestadorId;
  final String servicoOferecidoId;
  final String? enderecoId;
  final String enderecoLogradouro;
  final String enderecoNumero;
  final String? enderecoComplemento;
  final String enderecoBairro;
  final String enderecoCidade;
  final String enderecoEstado;
  final String enderecoCep;
  final DateTime horaInicio;
  final DateTime horaFim;
  final double valor;
  final StatusAgendamento status;
  final DateTime criadoEm;
  final DateTime? editadoEm;

  Agendamento({
    required this.id,
    required this.usuarioId,
    required this.prestadorId,
    required this.servicoOferecidoId,
    this.enderecoId,
    required this.enderecoLogradouro,
    required this.enderecoNumero,
    this.enderecoComplemento,
    required this.enderecoBairro,
    required this.enderecoCidade,
    required this.enderecoEstado,
    required this.enderecoCep,
    required this.horaInicio,
    required this.horaFim,
    required this.valor,
    required this.status,
    required this.criadoEm,
    this.editadoEm,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: JsonUtils.requireString(json, 'id'),
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
      prestadorId: JsonUtils.requireString(json, 'prestador_id'),
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
      enderecoId: JsonUtils.optionalString(json, 'endereco_id'),
      enderecoLogradouro: JsonUtils.requireString(json, 'endereco_logradouro'),
      enderecoNumero: JsonUtils.requireString(json, 'endereco_numero'),
      enderecoComplemento: JsonUtils.optionalString(
        json,
        'endereco_complemento',
      ),
      enderecoBairro: JsonUtils.requireString(json, 'endereco_bairro'),
      enderecoCidade: JsonUtils.requireString(json, 'endereco_cidade'),
      enderecoEstado: JsonUtils.requireString(json, 'endereco_estado'),
      enderecoCep: JsonUtils.requireString(json, 'endereco_cep'),
      horaInicio: JsonUtils.requireDateTime(json, 'hora_inicio'),
      horaFim: JsonUtils.requireDateTime(json, 'hora_fim'),
      valor: JsonUtils.requireDouble(json, 'valor'),
      status: StatusAgendamento.fromValor(
        JsonUtils.requireString(json, 'status'),
      ),
      criadoEm: JsonUtils.requireDateTime(json, 'criado_em'),
      editadoEm: JsonUtils.optionalDateTime(json, 'editado_em'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'prestador_id': prestadorId,
    'servico_oferecido_id': servicoOferecidoId,
    'endereco_id': enderecoId,
    'endereco_logradouro': enderecoLogradouro,
    'endereco_numero': enderecoNumero,
    'endereco_complemento': enderecoComplemento,
    'endereco_bairro': enderecoBairro,
    'endereco_cidade': enderecoCidade,
    'endereco_estado': enderecoEstado,
    'endereco_cep': enderecoCep,
    'hora_inicio': horaInicio.toIso8601String(),
    'hora_fim': horaFim.toIso8601String(),
    'valor': valor,
    'status': status.valor,
    'criado_em': criadoEm.toIso8601String(),
    'editado_em': editadoEm?.toIso8601String(),
  };
}
