import 'package:shared/shared.dart';

class ListarHorarioOcupadoPrestadorRequestDto implements WsMessage {
  final String prestadorId;

  ListarHorarioOcupadoPrestadorRequestDto({required this.prestadorId});

  @override
  TipoMensagem get tipo => TipoMensagem.listarHorariosOcupadosPrestador;

  factory ListarHorarioOcupadoPrestadorRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarHorarioOcupadoPrestadorRequestDto(
      prestadorId: JsonUtils.requireString(json, 'prestador_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'prestador_id': prestadorId,
  };
}

class ListarHorarioOcupadoPrestadorResponseDto implements WsMessage {
  final List<HorarioOcupado> horariosOcupados;

  ListarHorarioOcupadoPrestadorResponseDto({required this.horariosOcupados});

  @override
  TipoMensagem get tipo => TipoMensagem.listarHorariosOcupadosPrestadorOk;

  factory ListarHorarioOcupadoPrestadorResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListarHorarioOcupadoPrestadorResponseDto(
      horariosOcupados: (json['horarios_ocupados'] as List)
          .map((h) => HorarioOcupado.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'horarios_ocupados': horariosOcupados.map((h) => h.toJson()).toList(),
  };
}
