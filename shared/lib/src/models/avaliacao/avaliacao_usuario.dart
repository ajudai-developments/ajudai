import 'package:shared/src/dto/json_utils.dart';

/// Comentário/nota que um avaliador deixou sobre outro usuário (prestador
/// ou cliente), vinculado a um agendamento concluído. É isso que aparece
/// na seção de comentários do perfil.
class AvaliacaoUsuario {
  final String id;
  final String agendamentoId;
  final String avaliadorId;
  final String avaliadoId;
  final String avaliadorNome;
  final String? mensagem;
  final String? descricao;
  final double avaliacao;
  final DateTime criadoEm;

  AvaliacaoUsuario({
    required this.id,
    required this.agendamentoId,
    required this.avaliadorId,
    required this.avaliadoId,
    required this.avaliadorNome,
    this.mensagem,
    this.descricao,
    required this.avaliacao,
    required this.criadoEm,
  });

  factory AvaliacaoUsuario.fromJson(Map<String, dynamic> json) {
    return AvaliacaoUsuario(
      id: JsonUtils.requireString(json, 'id'),
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
      avaliadorId: JsonUtils.requireString(json, 'avaliador_id'),
      avaliadoId: JsonUtils.requireString(json, 'avaliado_id'),
      // vem de um join com usuarios; não existe coluna direta na tabela
      avaliadorNome: JsonUtils.requireString(json, 'avaliador_nome'),
      mensagem: JsonUtils.optionalString(json, 'mensagem'),
      descricao: JsonUtils.optionalString(json, 'descricao'),
      avaliacao: JsonUtils.requireDouble(json, 'avaliacao'),
      criadoEm: JsonUtils.requireDateTime(json, 'criado_em'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'agendamento_id': agendamentoId,
    'avaliador_id': avaliadorId,
    'avaliado_id': avaliadoId,
    'avaliador_nome': avaliadorNome,
    'mensagem': mensagem,
    'descricao': descricao,
    'avaliacao': avaliacao,
    'criado_em': criadoEm.toIso8601String(),
  };
}
