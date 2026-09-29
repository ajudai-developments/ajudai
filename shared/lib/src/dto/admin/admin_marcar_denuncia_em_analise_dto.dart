import 'package:shared/shared.dart';

class AdminMarcarDenunciaEmAnaliseRequestDto implements WsMessage {
  final String denunciaId;

  AdminMarcarDenunciaEmAnaliseRequestDto({required this.denunciaId});

  @override
  TipoMensagem get tipo => TipoMensagem.adminMarcarDenunciaEmAnalise;

  factory AdminMarcarDenunciaEmAnaliseRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminMarcarDenunciaEmAnaliseRequestDto(
      denunciaId: JsonUtils.requireString(json, 'denuncia_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'denuncia_id': denunciaId,
  };
}

class AdminMarcarDenunciaEmAnaliseResponseDto implements WsMessage {
  final String denunciaId;
  final StatusDenuncia status;

  AdminMarcarDenunciaEmAnaliseResponseDto({
    required this.denunciaId,
    required this.status,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.adminMarcarDenunciaEmAnaliseOk;

  factory AdminMarcarDenunciaEmAnaliseResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminMarcarDenunciaEmAnaliseResponseDto(
      denunciaId: JsonUtils.requireString(json, 'denuncia_id'),
      status: StatusDenuncia.fromValor(JsonUtils.requireString(json, 'status')),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'denuncia_id': denunciaId,
    'status': status.valor,
  };
}
