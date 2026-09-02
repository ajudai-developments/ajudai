import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/enums/status_verificacao.dart';

class Verificacao {
  final String id;
  final String usuarioId;
  final DateTime solicitadoEm;
  final DateTime? aprovadoEm;
  final String? aprovadoPorAdminId;
  final StatusVerificacao status;

  Verificacao({
    required this.id,
    required this.usuarioId,
    required this.solicitadoEm,
    this.aprovadoEm,
    this.aprovadoPorAdminId,
    required this.status,
  });

  factory Verificacao.fromJson(Map<String, dynamic> json) {
    return Verificacao(
      id: JsonUtils.requireString(json, 'id'),
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
      solicitadoEm: JsonUtils.requireDateTime(json, 'solicitado_em'),
      aprovadoEm: JsonUtils.optionalDateTime(json, 'aprovado_em'),
      aprovadoPorAdminId: JsonUtils.optionalString(
        json,
        'aprovado_por_admin_id',
      ),
      // NOTA: se o seu StatusVerificacao já tem um `fromValor`/`fromString`
      // próprio, troque a linha abaixo por ele. `.values.byName` funciona
      // porque os valores do enum do Postgres (pendente/aprovado/rejeitado)
      // são idênticos aos nomes dos membros do enum Dart.
      status: StatusVerificacao.values.byName(
        JsonUtils.requireString(json, 'status'),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'solicitado_em': solicitadoEm.toIso8601String(),
    'aprovado_em': aprovadoEm?.toIso8601String(),
    'aprovado_por_admin_id': aprovadoPorAdminId,
    'status': status.name,
  };
}
