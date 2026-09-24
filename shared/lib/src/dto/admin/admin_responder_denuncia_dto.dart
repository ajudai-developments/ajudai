import 'package:shared/shared.dart';

class AdminResponderDenunciaRequestDto implements WsMessage {
  final String denunciaId;
  final StatusDenuncia status;
  final String resposta;
  final bool removerPrestador;
  final bool banirUsuario;

  AdminResponderDenunciaRequestDto({
    required this.denunciaId,
    required this.status,
    required this.resposta,
    this.removerPrestador = false,
    this.banirUsuario = false,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.adminResponderDenuncia;

  factory AdminResponderDenunciaRequestDto.fromJson(Map<String, dynamic> json) {
    return AdminResponderDenunciaRequestDto(
      denunciaId: JsonUtils.requireString(json, 'denuncia_id'),
      status: StatusDenuncia.fromValor(JsonUtils.requireString(json, 'status')),
      resposta: JsonUtils.requireString(json, 'resposta'),
      removerPrestador: JsonUtils.optionalBool(json, 'remover_prestador'),
      banirUsuario: JsonUtils.optionalBool(json, 'banir_usuario'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'denuncia_id': denunciaId,
    'status': status.valor,
    'resposta': resposta,
    'remover_prestador': removerPrestador,
    'banir_usuario': banirUsuario,
  };
}

class AdminResponderDenunciaResponseDto implements WsMessage {
  final Denuncia denuncia;

  AdminResponderDenunciaResponseDto({required this.denuncia});

  @override
  TipoMensagem get tipo => TipoMensagem.adminResponderDenunciaOk;

  factory AdminResponderDenunciaResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminResponderDenunciaResponseDto(
      denuncia: Denuncia.fromJson(json['denuncia'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'denuncia': denuncia.toJson(),
  };
}
