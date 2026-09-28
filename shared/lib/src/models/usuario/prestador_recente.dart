import 'package:shared/shared.dart';

class PrestadorRecente {
  final String servicoOferecidoId;
  final String prestadorNome;
  final String? prestadorAvatarUrl;

  const PrestadorRecente({
    required this.servicoOferecidoId,
    required this.prestadorNome,
    required this.prestadorAvatarUrl,
  });

  factory PrestadorRecente.fromJson(Map<String, dynamic> json) {
    return PrestadorRecente(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
      prestadorNome: JsonUtils.requireString(json, 'prestador_nome'),
      prestadorAvatarUrl: JsonUtils.optionalString(
        json,
        'prestador_avatar_url',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'servico_oferecido_id': servicoOferecidoId,
    'prestador_nome': prestadorNome,
    'prestador_avatar_url': prestadorAvatarUrl,
  };
}
