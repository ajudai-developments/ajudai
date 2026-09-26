// perfil_estatisticas.dart
import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/conquista/conquista_usuario.dart';
import 'requisito_verificacao.dart';

class PerfilEstatisticas {
  final DateTime membroDesde;
  final bool verificado;
  final List<RequisitoVerificacao> requisitosVerificacao;

  final double? mediaAvaliacao;
  final int totalAvaliacoes;

  final int agendamentosConcluidosComoCliente;
  final int agendamentosCanceladosComoCliente;
  final int? agendamentosConcluidosComoPrestador;
  final int? agendamentosCanceladosComoPrestador;

  final int? tempoMedioRespostaSegundos;

  final int totalConquistas;
  final int totalConquistasDisponiveis;
  final List<ConquistaUsuario> conquistas;

  PerfilEstatisticas({
    required this.membroDesde,
    required this.verificado,
    required this.requisitosVerificacao,
    this.mediaAvaliacao,
    required this.totalAvaliacoes,
    required this.agendamentosConcluidosComoCliente,
    required this.agendamentosCanceladosComoCliente,
    this.agendamentosConcluidosComoPrestador,
    this.agendamentosCanceladosComoPrestador,
    this.tempoMedioRespostaSegundos,
    required this.totalConquistas,
    required this.totalConquistasDisponiveis,
    required this.conquistas,
  });

  factory PerfilEstatisticas.fromJson(Map<String, dynamic> json) {
    final requisitos = JsonUtils.requireListaDeMapas(
      json,
      'requisitos_verificacao',
    );
    final conquistas = JsonUtils.requireListaDeMapas(json, 'conquistas');

    return PerfilEstatisticas(
      membroDesde: JsonUtils.requireDateTime(json, 'membro_desde'),
      verificado: json['verificado'] as bool,
      requisitosVerificacao: requisitos
          .map(RequisitoVerificacao.fromJson)
          .toList(),
      mediaAvaliacao: JsonUtils.optionalDouble(json, 'media_avaliacao'),
      totalAvaliacoes: JsonUtils.requireInt(json, 'total_avaliacoes'),
      agendamentosConcluidosComoCliente: JsonUtils.requireInt(
        json,
        'agendamentos_concluidos_cliente',
      ),
      agendamentosCanceladosComoCliente: JsonUtils.requireInt(
        json,
        'agendamentos_cancelados_cliente',
      ),
      agendamentosConcluidosComoPrestador:
          json['agendamentos_concluidos_prestador'] == null
          ? null
          : JsonUtils.requireInt(json, 'agendamentos_concluidos_prestador'),
      agendamentosCanceladosComoPrestador:
          json['agendamentos_cancelados_prestador'] == null
          ? null
          : JsonUtils.requireInt(json, 'agendamentos_cancelados_prestador'),
      tempoMedioRespostaSegundos: json['tempo_medio_resposta_segundos'] == null
          ? null
          : JsonUtils.requireInt(json, 'tempo_medio_resposta_segundos'),
      totalConquistas: JsonUtils.requireInt(json, 'total_conquistas'),
      totalConquistasDisponiveis: JsonUtils.requireInt(
        json,
        'total_conquistas_disponiveis',
      ),
      conquistas: conquistas.map(ConquistaUsuario.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'membro_desde': membroDesde.toIso8601String(),
    'verificado': verificado,
    'requisitos_verificacao': requisitosVerificacao
        .map((r) => r.toJson())
        .toList(),
    'media_avaliacao': mediaAvaliacao,
    'total_avaliacoes': totalAvaliacoes,
    'agendamentos_concluidos_cliente': agendamentosConcluidosComoCliente,
    'agendamentos_cancelados_cliente': agendamentosCanceladosComoCliente,
    'agendamentos_concluidos_prestador': agendamentosConcluidosComoPrestador,
    'agendamentos_cancelados_prestador': agendamentosCanceladosComoPrestador,
    'tempo_medio_resposta_segundos': tempoMedioRespostaSegundos,
    'total_conquistas': totalConquistas,
    'total_conquistas_disponiveis': totalConquistasDisponiveis,
    'conquistas': conquistas.map((c) => c.toJson()).toList(),
  };
}
