import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/enums/status_contestacao.dart';
import 'package:shared/src/models/arquivo_anexado.dart';

class Contestacao {
  final String id;
  final String agendamentoId;
  final String contestadorId;
  final String descricao;
  final StatusContestacao status;
  final DateTime criadoEm;
  final List<ArquivoAnexado> arquivos;

  Contestacao({
    required this.id,
    required this.agendamentoId,
    required this.contestadorId,
    required this.descricao,
    required this.status,
    required this.criadoEm,
    required this.arquivos,
  });

  factory Contestacao.fromJson(Map<String, dynamic> json) {
    final arquivos = JsonUtils.requireListaDeMapas(json, 'arquivos');
    return Contestacao(
      id: JsonUtils.requireString(json, 'id'),
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
      contestadorId: JsonUtils.requireString(json, 'contestador_id'),
      descricao: JsonUtils.requireString(json, 'descricao'),
      status: StatusContestacao.fromValor(
        JsonUtils.requireString(json, 'status'),
      ),
      criadoEm: JsonUtils.requireDateTime(json, 'criado_em'),
      arquivos: arquivos.map(ArquivoAnexado.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'agendamento_id': agendamentoId,
    'contestador_id': contestadorId,
    'descricao': descricao,
    'status': status.valor,
    'criado_em': criadoEm.toIso8601String(),
    'arquivos': arquivos.map((a) => a.toJson()).toList(),
  };
}
