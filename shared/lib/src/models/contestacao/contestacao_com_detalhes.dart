import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/enums/status_contestacao.dart';
import 'package:shared/src/models/enums/status_agendamento.dart';
import 'package:shared/src/models/arquivos/arquivo_anexado.dart';

class ContestacaoComDetalhes {
  final String id;
  final String agendamentoId;
  final String contestadorId;
  final String contestadorNome;
  final String descricao;
  final StatusContestacao status;
  final DateTime criadoEm;
  final String? respostaAdmin;
  final String? respondidoPorAdminId;
  final DateTime? respondidoEm;
  final StatusAgendamento agendamentoStatus;
  final DateTime horaInicio;
  final DateTime horaFim;
  final double valor;
  final List<ArquivoAnexado> arquivos;

  ContestacaoComDetalhes({
    required this.id,
    required this.agendamentoId,
    required this.contestadorId,
    required this.contestadorNome,
    required this.descricao,
    required this.status,
    required this.criadoEm,
    this.respostaAdmin,
    this.respondidoPorAdminId,
    this.respondidoEm,
    required this.agendamentoStatus,
    required this.horaInicio,
    required this.horaFim,
    required this.valor,
    required this.arquivos,
  });

  factory ContestacaoComDetalhes.fromJson(Map<String, dynamic> json) {
    final arquivos = JsonUtils.requireListaDeMapas(json, 'arquivos');
    return ContestacaoComDetalhes(
      id: JsonUtils.requireString(json, 'id'),
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
      contestadorId: JsonUtils.requireString(json, 'contestador_id'),
      contestadorNome: JsonUtils.requireString(json, 'contestador_nome'),
      descricao: JsonUtils.requireString(json, 'descricao'),
      status: StatusContestacao.fromValor(
        JsonUtils.requireString(json, 'status'),
      ),
      criadoEm: JsonUtils.requireDateTime(json, 'criado_em'),
      respostaAdmin: JsonUtils.optionalString(json, 'resposta_admin'),
      respondidoPorAdminId: JsonUtils.optionalString(
        json,
        'respondido_por_admin_id',
      ),
      respondidoEm: JsonUtils.optionalDateTime(json, 'respondido_em'),
      agendamentoStatus: StatusAgendamento.fromValor(
        JsonUtils.requireString(json, 'agendamento_status'),
      ),
      horaInicio: JsonUtils.requireDateTime(json, 'hora_inicio'),
      horaFim: JsonUtils.requireDateTime(json, 'hora_fim'),
      valor: JsonUtils.requireDouble(json, 'valor'),
      arquivos: arquivos.map(ArquivoAnexado.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'agendamento_id': agendamentoId,
    'contestador_id': contestadorId,
    'contestador_nome': contestadorNome,
    'descricao': descricao,
    'status': status.valor,
    'criado_em': criadoEm.toIso8601String(),
    'resposta_admin': respostaAdmin,
    'respondido_por_admin_id': respondidoPorAdminId,
    'respondido_em': respondidoEm?.toIso8601String(),
    'agendamento_status': agendamentoStatus.valor,
    'hora_inicio': horaInicio.toIso8601String(),
    'hora_fim': horaFim.toIso8601String(),
    'valor': valor,
    'arquivos': arquivos.map((a) => a.toJson()).toList(),
  };
}
