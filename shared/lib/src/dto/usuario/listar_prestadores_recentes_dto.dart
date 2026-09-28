import 'package:shared/shared.dart';

class ListarPrestadoresRecentesRequestDto implements WsMessage {
  final int? limite;

  const ListarPrestadoresRecentesRequestDto({this.limite});

  @override
  TipoMensagem get tipo => TipoMensagem.listarPrestadoresRecente;

  factory ListarPrestadoresRecentesRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarPrestadoresRecentesRequestDto(limite: json['limite'] as int?);
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    if (limite != null) 'limite': limite,
  };
}

class ListarPrestadoresRecentesResponseDto implements WsMessage {
  final List<PrestadorRecente> prestadores;

  const ListarPrestadoresRecentesResponseDto({required this.prestadores});

  @override
  TipoMensagem get tipo => TipoMensagem.listarPrestadoresRecenteOk;

  factory ListarPrestadoresRecentesResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final lista = (json['prestadores'] as List<dynamic>? ?? const []);
    return ListarPrestadoresRecentesResponseDto(
      prestadores: lista
          .map((e) => PrestadorRecente.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'prestadores': prestadores.map((p) => p.toJson()).toList(),
  };
}
