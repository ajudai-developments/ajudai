import 'package:shared/src/dto/json_utils.dart';

class SolicitacaoPrecoResumo {
  final String id;
  final String solicitanteId;
  final double valorAnterior;
  final double valorNovo;
  final String motivo;
  final String status;
  final DateTime solicitadoEm;

  SolicitacaoPrecoResumo({
    required this.id,
    required this.solicitanteId,
    required this.valorAnterior,
    required this.valorNovo,
    required this.motivo,
    required this.status,
    required this.solicitadoEm,
  });

  factory SolicitacaoPrecoResumo.fromJson(Map<String, dynamic> json) {
    return SolicitacaoPrecoResumo(
      id: JsonUtils.requireString(json, 'id'),
      solicitanteId: JsonUtils.requireString(json, 'solicitante_id'),
      valorAnterior: JsonUtils.requireDouble(json, 'valor_anterior'),
      valorNovo: JsonUtils.requireDouble(json, 'valor_novo'),
      motivo: JsonUtils.requireString(json, 'motivo'),
      status: JsonUtils.requireString(json, 'status'),
      solicitadoEm: JsonUtils.requireDateTime(json, 'solicitado_em'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'solicitante_id': solicitanteId,
    'valor_anterior': valorAnterior,
    'valor_novo': valorNovo,
    'motivo': motivo,
    'status': status,
    'solicitado_em': solicitadoEm.toIso8601String(),
  };
}
