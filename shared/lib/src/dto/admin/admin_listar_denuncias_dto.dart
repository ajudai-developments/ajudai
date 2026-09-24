import 'package:shared/shared.dart';

class AdminListarDenunciasRequestDto implements WsMessage {
  final StatusDenuncia? status;

  AdminListarDenunciasRequestDto({this.status});

  @override
  TipoMensagem get tipo => TipoMensagem.adminListarDenuncias;

  factory AdminListarDenunciasRequestDto.fromJson(Map<String, dynamic> json) {
    final valor = JsonUtils.optionalString(json, 'status');
    return AdminListarDenunciasRequestDto(
      status: valor == null ? null : StatusDenuncia.fromValor(valor),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'status': status?.valor,
  };
}

class AdminListarDenunciasResponseDto implements WsMessage {
  final List<DenunciaComDetalhes> denuncias;

  AdminListarDenunciasResponseDto({required this.denuncias});

  @override
  TipoMensagem get tipo => TipoMensagem.adminListarDenunciasOk;

  factory AdminListarDenunciasResponseDto.fromJson(Map<String, dynamic> json) {
    final lista = JsonUtils.requireListaDeMapas(json, 'denuncias');
    return AdminListarDenunciasResponseDto(
      denuncias: lista.map(DenunciaComDetalhes.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'denuncias': denuncias.map((d) => d.toJson()).toList(),
  };
}
