import 'package:shared/shared.dart';

/// Visão do prestador sobre um dos SEUS PRÓPRIOS serviços oferecidos —
/// usado na tela de gerenciamento (`MeusServicosOferecidosScreen`).
/// Diferente de [ServicoOferecidoPreview] (usado por quem VAI
/// contratar), aqui não faz sentido repetir dados do prestador (ele já
/// sabe quem é) — o foco é o que ele precisa pra gerenciar: descrição
/// completa, se está ativo, e como esse serviço específico está sendo
/// avaliado.
class ServicoOferecidoDoPrestador {
  final String servicoOferecidoId;
  final String servicoNome;
  final String categoriaNome;
  final String descricao;
  final double valor;
  final bool ativo;
  final double? mediaAvaliacaoServico;
  final int quantidadeAvaliacoesServico;

  ServicoOferecidoDoPrestador({
    required this.servicoOferecidoId,
    required this.servicoNome,
    required this.categoriaNome,
    required this.descricao,
    required this.valor,
    required this.ativo,
    this.mediaAvaliacaoServico,
    required this.quantidadeAvaliacoesServico,
  });

  factory ServicoOferecidoDoPrestador.fromJson(Map<String, dynamic> json) {
    return ServicoOferecidoDoPrestador(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
      servicoNome: JsonUtils.requireString(json, 'servico_nome'),
      categoriaNome: JsonUtils.requireString(json, 'categoria_nome'),
      descricao: JsonUtils.requireString(json, 'descricao'),
      valor: JsonUtils.requireDouble(json, 'valor'),
      ativo: json['ativo'] as bool,
      mediaAvaliacaoServico: JsonUtils.optionalDouble(
        json,
        'media_avaliacao_servico',
      ),
      quantidadeAvaliacoesServico: JsonUtils.requireInt(
        json,
        'quantidade_avaliacoes_servico',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'servico_oferecido_id': servicoOferecidoId,
    'servico_nome': servicoNome,
    'categoria_nome': categoriaNome,
    'descricao': descricao,
    'valor': valor,
    'ativo': ativo,
    'media_avaliacao_servico': mediaAvaliacaoServico,
    'quantidade_avaliacoes_servico': quantidadeAvaliacoesServico,
  };
}
