import 'package:shared/shared.dart';

/// Dados completos para a tela de detalhe: o card de preview já foi
/// mostrado antes, aqui é o "clicou e abriu o perfil/serviço".
class ObterServicoOferecidoResponseDto implements WsMessage {
  final ServicoOferecido servicoOferecido;
  final Servico servico;
  final Categoria categoria;
  final Usuario prestador;
  final List<ConquistaUsuario> selos;
  final double? mediaAvaliacao;
  final int quantidadeAvaliacoes;
  final List<AvaliacaoUsuario> comentarios;

  ObterServicoOferecidoResponseDto({
    required this.servicoOferecido,
    required this.servico,
    required this.categoria,
    required this.prestador,
    required this.selos,
    this.mediaAvaliacao,
    required this.quantidadeAvaliacoes,
    required this.comentarios,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.obterServicoOferecidoOk;

  factory ObterServicoOferecidoResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final selos = JsonUtils.requireListaDeMapas(json, 'selos');
    final comentarios = JsonUtils.requireListaDeMapas(json, 'comentarios');

    return ObterServicoOferecidoResponseDto(
      servicoOferecido: ServicoOferecido.fromJson(
        json['servico_oferecido'] as Map<String, dynamic>,
      ),
      servico: Servico.fromJson(json['servico'] as Map<String, dynamic>),
      categoria: Categoria.fromJson(
        json['categoria'] as Map<String, dynamic>,
      ),
      prestador: Usuario.fromJson(json['prestador'] as Map<String, dynamic>),
      selos: selos.map(ConquistaUsuario.fromJson).toList(),
      mediaAvaliacao: JsonUtils.optionalDouble(json, 'media_avaliacao'),
      quantidadeAvaliacoes: JsonUtils.requireInt(
        json,
        'quantidade_avaliacoes',
      ),
      comentarios: comentarios.map(AvaliacaoUsuario.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_oferecido': servicoOferecido.toJson(),
    'servico': servico.toJson(),
    'categoria': categoria.toJson(),
    'prestador': prestador.toJson(),
    'selos': selos.map((s) => s.toJson()).toList(),
    'media_avaliacao': mediaAvaliacao,
    'quantidade_avaliacoes': quantidadeAvaliacoes,
    'comentarios': comentarios.map((c) => c.toJson()).toList(),
  };
}
