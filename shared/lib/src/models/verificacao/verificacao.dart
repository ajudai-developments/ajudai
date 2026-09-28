import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/enums/status_verificacao.dart';

class Verificacao {
  final String id;
  final String usuarioId;
  final DateTime solicitadoEm;
  final DateTime? alteradoEm;
  final String? alteradoPorAdminId;
  final StatusVerificacao status;
  final String? motivoRejeicao;

  Verificacao({
    required this.id,
    required this.usuarioId,
    required this.solicitadoEm,
    this.alteradoEm,
    this.alteradoPorAdminId,
    required this.status,
    this.motivoRejeicao,
  });

  factory Verificacao.fromJson(Map<String, dynamic> json) {
    return Verificacao(
      id: JsonUtils.requireString(json, 'id'),
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
      solicitadoEm: JsonUtils.requireDateTime(json, 'solicitado_em'),
      alteradoEm: JsonUtils.optionalDateTime(json, 'alterado_em'),
      alteradoPorAdminId: JsonUtils.optionalString(
        json,
        'alterado_por_admin_id',
      ),
      motivoRejeicao: JsonUtils.optionalString(json, 'motivo_rejeicao'),
      status: StatusVerificacao.values.byName(
        JsonUtils.requireString(json, 'status'),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'solicitado_em': solicitadoEm.toIso8601String(),
    'alterado_em': alteradoEm?.toIso8601String(),
    'alterado_por_admin_id': alteradoPorAdminId,
    'status': status.name,
    'motivo_rejeicao': motivoRejeicao,
  };
}
