import 'package:shared/shared.dart';

class BuscarPerfilEstatisticasRequestDto implements WsMessage {
  BuscarPerfilEstatisticasRequestDto();

  @override
  TipoMensagem get tipo => TipoMensagem.buscarPerfilEstatisticas;

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo.valor};

  factory BuscarPerfilEstatisticasRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return BuscarPerfilEstatisticasRequestDto();
  }
}

class BuscarPerfilEstatisticasResponseDto implements WsMessage {
  final PerfilEstatisticas estatisticas;

  const BuscarPerfilEstatisticasResponseDto({required this.estatisticas});

  factory BuscarPerfilEstatisticasResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return BuscarPerfilEstatisticasResponseDto(
      estatisticas: PerfilEstatisticas.fromJson(
        json['estatisticas'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.buscarPerfilEstatisticasOk;

  @override
  Map<String, dynamic> toJson() => {
    "tipo": tipo.valor,
    "estatisticas": estatisticas.toJson(),
  };
}
