import '../json_utils.dart';

class ListarVerificacoesResponseDto {
  final String verificacaoId;
  final String usuarioId;
  final String status;
  final DateTime solicitadoEm;
  final DateTime? aprovadoEm;
  final String? aprovadoPorAdminId;

  const ListarVerificacoesResponseDto({
    required this.verificacaoId,
    required this.usuarioId,
    required this.status,
    required this.solicitadoEm,
    this.aprovadoEm,
    this.aprovadoPorAdminId,
  });

  factory ListarVerificacoesResponseDto.fromJson(Map<String, dynamic> json) {
    return ListarVerificacoesResponseDto(
      verificacaoId: JsonUtils.requireString(json, 'verificacaoId'),
      usuarioId: JsonUtils.requireString(json, 'usuarioId'),
      status: JsonUtils.requireString(json, 'status'),
      solicitadoEm: DateTime.parse(
        JsonUtils.requireString(json, 'solicitadoEm'),
      ),
      aprovadoEm: json['aprovadoEm'] is String
          ? DateTime.tryParse(json['aprovadoEm'] as String)
          : null,
      aprovadoPorAdminId: JsonUtils.optionalString(json, 'aprovadoPorAdminId'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verificacaoId': verificacaoId,
      'usuarioId': usuarioId,
      'status': status,
      'solicitadoEm': solicitadoEm.toIso8601String(),
      'aprovadoEm': aprovadoEm?.toIso8601String(),
      'aprovadoPorAdminId': aprovadoPorAdminId,
    };
  }
}
