import 'package:shared/shared.dart';
import 'package:shared/src/models/enums/status_verificacao.dart';

class SolicitarPrestadorResponseDto {
  final String verificacaoId;
  final String usuarioId;
  final StatusVerificacao status;
  final DateTime solicitadoEm;
  const SolicitarPrestadorResponseDto({
    required this.verificacaoId,
    required this.usuarioId,
    required this.status,
    required this.solicitadoEm,
  });
  factory SolicitarPrestadorResponseDto.fromJson(Map<String, dynamic> json) {
    return SolicitarPrestadorResponseDto(
      verificacaoId: JsonUtils.requireString(json, 'verificacao_id'),
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
      status: StatusVerificacao.fromString(
        JsonUtils.requireString(json, 'status'),
      ),
      solicitadoEm: DateTime.parse(
        JsonUtils.requireString(json, 'solicitado_em'),
      ),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'verificacao_id': verificacaoId,
      'usuario_id': usuarioId,
      'status': status.name,
      'solicitado_em': solicitadoEm.toIso8601String(),
    };
  }
}
