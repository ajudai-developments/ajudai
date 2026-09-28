import 'package:shared/shared.dart';

class PrestadorRecente {
  final String servicoOferecidoId;
  final String prestadorNome;
  final String? prestadorAvatarUrl;
  final bool prestadorVerificado;

  const PrestadorRecente({
    required this.servicoOferecidoId,
    required this.prestadorNome,
    required this.prestadorAvatarUrl,
    required this.prestadorVerificado,
  });

  factory PrestadorRecente.fromJson(Map<String, dynamic> json) {
    return PrestadorRecente(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
      prestadorNome: JsonUtils.requireString(json, 'prestador_nome'),
      prestadorAvatarUrl: JsonUtils.optionalString(
        json,
        'prestador_avatar_url',
      ),
      prestadorVerificado: JsonUtils.requireBool(json, 'prestador_verificado'),
    );
  }

  Map<String, dynamic> toJson() => {
    'servico_oferecido_id': servicoOferecidoId,
    'prestador_nome': prestadorNome,
    'prestador_avatar_url': prestadorAvatarUrl,
    'prestador_verificado': prestadorVerificado,
  };
}
