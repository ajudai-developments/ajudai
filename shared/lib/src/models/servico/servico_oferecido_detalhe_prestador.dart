import '../../dto/json_utils.dart';
import '../avaliacao/avaliacao_servico.dart';
import 'estatisticas_servico_oferecido.dart';

/// Visão do PRESTADOR sobre o desempenho de um dos seus serviços
/// oferecidos: pedidos gerados, faturamento, avaliação e comentários
/// recebidos.
///
/// Diferente de [ServicoOferecido] (usado por quem VAI contratar) — aqui
/// não faz sentido repetir dados do prestador (ele já sabe quem é), o
/// foco é o que ele precisa pra gerenciar e entender como o serviço está
/// performando.
class ServicoOferecidoDetalhePrestador {
  final String servicoOferecidoId;
  final String descricao;
  final double valor;
  final bool ativo;
  final String servicoNome;
  final String categoriaNome;
  final EstatisticasServicoOferecido estatisticas;
  final List<AvaliacaoServico> comentarios;

  ServicoOferecidoDetalhePrestador({
    required this.servicoOferecidoId,
    required this.descricao,
    required this.valor,
    required this.ativo,
    required this.servicoNome,
    required this.categoriaNome,
    required this.estatisticas,
    required this.comentarios,
  });

  factory ServicoOferecidoDetalhePrestador.fromJson(Map<String, dynamic> json) {
    final servicoOferecido = json['servico_oferecido'] as Map<String, dynamic>;
    final servico = json['servico'] as Map<String, dynamic>;
    final categoria = json['categoria'] as Map<String, dynamic>;
    final comentarios = JsonUtils.requireListaDeMapas(
      json,
      'comentarios_servico',
    );

    return ServicoOferecidoDetalhePrestador(
      servicoOferecidoId: JsonUtils.requireString(servicoOferecido, 'id'),
      descricao: JsonUtils.requireString(servicoOferecido, 'descricao'),
      valor: JsonUtils.requireDouble(servicoOferecido, 'valor'),
      ativo: servicoOferecido['ativo'] as bool,
      servicoNome: JsonUtils.requireString(servico, 'nome'),
      categoriaNome: JsonUtils.requireString(categoria, 'nome'),
      estatisticas: EstatisticasServicoOferecido.fromJson(
        json['estatisticas'] as Map<String, dynamic>,
      ),
      comentarios: comentarios.map(AvaliacaoServico.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'servico_oferecido': {
      'id': servicoOferecidoId,
      'descricao': descricao,
      'valor': valor,
      'ativo': ativo,
    },
    'servico': {'nome': servicoNome},
    'categoria': {'nome': categoriaNome},
    'estatisticas': estatisticas.toJson(),
    'comentarios_servico': comentarios.map((c) => c.toJson()).toList(),
  };
}
