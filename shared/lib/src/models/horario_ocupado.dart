import 'package:shared/shared.dart';

class HorarioOcupado {
  final DateTime horaInicio;
  final DateTime horaFim;

  HorarioOcupado({required this.horaInicio, required this.horaFim});

  factory HorarioOcupado.fromJson(Map<String, dynamic> json) {
    return HorarioOcupado(
      horaInicio: JsonUtils.requireDateTime(json, 'hora_inicio'),
      horaFim: JsonUtils.requireDateTime(json, 'hora_fim'),
    );
  }

  Map<String, dynamic> toJson() => {
    'hora_inicio': horaInicio.toUtc().toIso8601String(),
    'hora_fim': horaFim.toUtc().toIso8601String(),
  };
}
