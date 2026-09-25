import 'package:shared/src/dto/json_utils.dart';

enum OrigemTimelineAgendamento { sistema, historico, evento }

/// Um item da linha do tempo do agendamento. O campo [tipo] é o valor
/// cru do enum de origem (ex: 'status', 'preco', 'alerta_atraso',
/// 'criado') — a UI decide o ícone/texto exibido com base nele.
/// Campos como [status], [valor], [horaInicio] só vêm preenchidos
/// quando [origem] é [OrigemTimelineAgendamento.historico].
class TimelineItemAgendamento {
  final OrigemTimelineAgendamento origem;
  final String tipo;
  final DateTime ocorridoEm;

  final String? status;
  final double? valor;
  final DateTime? horaInicio;
  final DateTime? horaFim;
  final String? enderecoLogradouro;
  final String? enderecoNumero;
  final String? alteradoPorUsuarioId;
  final String? alteradoPorNome;

  TimelineItemAgendamento({
    required this.origem,
    required this.tipo,
    required this.ocorridoEm,
    this.status,
    this.valor,
    this.horaInicio,
    this.horaFim,
    this.enderecoLogradouro,
    this.enderecoNumero,
    this.alteradoPorUsuarioId,
    this.alteradoPorNome,
  });

  factory TimelineItemAgendamento.fromJson(Map<String, dynamic> json) {
    return TimelineItemAgendamento(
      origem: OrigemTimelineAgendamento.values.firstWhere(
        (e) => e.name == json['origem'],
        orElse: () => throw FormatException(
          'origem de timeline inválida: "${json['origem']}"',
        ),
      ),
      tipo: JsonUtils.requireString(json, 'tipo'),
      ocorridoEm: JsonUtils.requireDateTime(json, 'ocorrido_em'),
      status: JsonUtils.optionalString(json, 'status'),
      valor: json['valor'] == null
          ? null
          : JsonUtils.requireDouble(json, 'valor'),
      horaInicio: JsonUtils.optionalDateTime(json, 'hora_inicio'),
      horaFim: JsonUtils.optionalDateTime(json, 'hora_fim'),
      enderecoLogradouro: JsonUtils.optionalString(json, 'endereco_logradouro'),
      enderecoNumero: JsonUtils.optionalString(json, 'endereco_numero'),
      alteradoPorUsuarioId: JsonUtils.optionalString(
        json,
        'alterado_por_usuario_id',
      ),
      alteradoPorNome: JsonUtils.optionalString(json, 'alterado_por_nome'),
    );
  }

  Map<String, dynamic> toJson() => {
    'origem': origem.name,
    'tipo': tipo,
    'ocorrido_em': ocorridoEm.toIso8601String(),
    'status': status,
    'valor': valor,
    'hora_inicio': horaInicio?.toIso8601String(),
    'hora_fim': horaFim?.toIso8601String(),
    'endereco_logradouro': enderecoLogradouro,
    'endereco_numero': enderecoNumero,
    'alterado_por_usuario_id': alteradoPorUsuarioId,
    'alterado_por_nome': alteradoPorNome,
  };
}
