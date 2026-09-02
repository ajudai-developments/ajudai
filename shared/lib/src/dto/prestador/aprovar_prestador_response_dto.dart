import 'package:shared/shared.dart';

class AprovarPrestadorResponseDto {
  final String verificacaoId;
  final String usuarioId;
  final String status;
  final DateTime solicitadoEm;
  final DateTime aprovadoEm;
  final String aprovadoPorAdminId;

  final StatusPrestador statusPrestador;
  final UserRole userRole;

  const AprovarPrestadorResponseDto({
    required this.verificacaoId,
    required this.usuarioId,
    required this.status,
    required this.solicitadoEm,
    required this.aprovadoEm,
    required this.aprovadoPorAdminId,
    required this.statusPrestador,
    required this.userRole,
  });

  factory AprovarPrestadorResponseDto.fromJson(Map<String, dynamic> json) {
    return AprovarPrestadorResponseDto(
      verificacaoId: JsonUtils.requireString(json, 'verificacao_id'),
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
      status: JsonUtils.requireString(json, 'status'),
      solicitadoEm: DateTime.parse(
        JsonUtils.requireString(json, 'solicitado_em'),
      ),
      aprovadoEm: DateTime.parse(JsonUtils.requireString(json, 'aprovado_em')),
      aprovadoPorAdminId: JsonUtils.requireString(
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
      'aprovado_em': aprovadoEm.toIso8601String(),
      'aprovado_por_admin_id': aprovadoPorAdminId,
      'status_prestador': statusPrestador,
      'user_role': userRole,
    };
  }
}
