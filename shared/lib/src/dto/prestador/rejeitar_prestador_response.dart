import 'package:shared/shared.dart';

class RejeitarPrestadorResponseDto {
  final String verificacaoId;
  final String usuarioId;
  final String status;
  final DateTime solicitadoEm;
  final String? aprovadoPorAdminId;
  final StatusPrestador statusPrestador;
  final UserRole userRole;

  const RejeitarPrestadorResponseDto({
    required this.verificacaoId,
    required this.usuarioId,
    required this.status,
    required this.solicitadoEm,
    this.aprovadoPorAdminId,
    required this.statusPrestador,
    required this.userRole,
  });

  factory RejeitarPrestadorResponseDto.fromJson(Map<String, dynamic> json) {
    return RejeitarPrestadorResponseDto(
      verificacaoId: JsonUtils.requireString(json, 'verificacao_id'),
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
      status: JsonUtils.requireString(json, 'status'),
      solicitadoEm: DateTime.parse(
        JsonUtils.requireString(json, 'solicitado_em'),
      ),
      aprovadoPorAdminId: JsonUtils.optionalString(
        json,
        'aprovado_por_admin_id',
      ),
      statusPrestador: StatusPrestador.fromString(
        JsonUtils.requireString(json, 'status_prestador'),
      ),
      userRole: UserRole.fromString(JsonUtils.requireString(json, 'user_role')),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verificacao_id': verificacaoId,
      'usuario_id': usuarioId,
      'status': status,
      'solicitado_em': solicitadoEm.toIso8601String(),
      'aprovado_por_admin_id': aprovadoPorAdminId,
      'status_prestador': statusPrestador.name,
      'user_role': userRole.name,
    };
  }
}
