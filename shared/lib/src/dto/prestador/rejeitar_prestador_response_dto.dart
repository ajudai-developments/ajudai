import 'package:shared/shared.dart';

class RejeitarPrestadorResponseDto implements WsMessage {
  final String motivo;

  RejeitarPrestadorResponseDto({required this.motivo});

  @override
  TipoMensagem get tipo => TipoMensagem.rejeitarPrestadorOk;

  factory RejeitarPrestadorResponseDto.fromJson(Map<String, dynamic> json) {
    return RejeitarPrestadorResponseDto(
      motivo: JsonUtils.requireString(json, 'motivo'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor, 'motivo': motivo};
}
