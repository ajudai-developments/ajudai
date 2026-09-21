import 'package:shared/shared.dart';

class ObterPerfilPublicoRequestDto implements WsMessage {
  final String usuarioId;

  ObterPerfilPublicoRequestDto({required this.usuarioId});

  @override
  TipoMensagem get tipo => TipoMensagem.obterPerfilPublico;

  factory ObterPerfilPublicoRequestDto.fromJson(Map<String, dynamic> json) {
    return ObterPerfilPublicoRequestDto(
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'usuario_id': usuarioId,
  };
}

class ObterPerfilPublicoResponseDto implements WsMessage {
  final UsuarioBasico usuario;
  final bool ehPrestador;
  final int quantidadeServicosConcluidos;
  final List<ServicoOferecidoResumo> servicosOferecidos;
  final List<ConquistaUsuario> selos;
  final double? mediaAvaliacao;
  final int quantidadeAvaliacoes;
  final List<AvaliacaoUsuario> comentarios;
  final double? mediaAvaliacaoServicos;
  final int quantidadeAvaliacoesServicos;
  final List<AvaliacaoServico> comentariosServicos;

  ObterPerfilPublicoResponseDto({
    required this.usuario,
    required this.ehPrestador,
    required this.quantidadeServicosConcluidos,
    required this.servicosOferecidos,
    required this.selos,
    this.mediaAvaliacao,
    required this.quantidadeAvaliacoes,
    required this.comentarios,
    this.mediaAvaliacaoServicos,
    required this.quantidadeAvaliacoesServicos,
    required this.comentariosServicos,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.obterPerfilPublicoOk;

  factory ObterPerfilPublicoResponseDto.fromJson(Map<String, dynamic> json) {
    final servicos = JsonUtils.requireListaDeMapas(json, 'servicos_oferecidos');
    final selos = JsonUtils.requireListaDeMapas(json, 'selos');
    final comentarios = JsonUtils.requireListaDeMapas(json, 'comentarios');
    final comentariosServicos = JsonUtils.requireListaDeMapas(
      json,
      'comentarios_servicos',
    );

    return ObterPerfilPublicoResponseDto(
      usuario: UsuarioBasico.fromJson(json['usuario'] as Map<String, dynamic>),
      ehPrestador: json['eh_prestador'] as bool,
      quantidadeServicosConcluidos: JsonUtils.requireInt(
        json,
        'quantidade_servicos_concluidos',
      ),
      servicosOferecidos: servicos
          .map(ServicoOferecidoResumo.fromJson)
          .toList(),
      selos: selos.map(ConquistaUsuario.fromJson).toList(),
      mediaAvaliacao: JsonUtils.optionalDouble(json, 'media_avaliacao'),
      quantidadeAvaliacoes: JsonUtils.requireInt(json, 'quantidade_avaliacoes'),
      comentarios: comentarios.map(AvaliacaoUsuario.fromJson).toList(),
      mediaAvaliacaoServicos: JsonUtils.optionalDouble(
        json,
        'media_avaliacao_servicos',
      ),
      quantidadeAvaliacoesServicos: JsonUtils.requireInt(
        json,
        'quantidade_avaliacoes_servicos',
      ),
      comentariosServicos: comentariosServicos
          .map(AvaliacaoServico.fromJson)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'usuario': usuario.toJson(),
    'eh_prestador': ehPrestador,
    'quantidade_servicos_concluidos': quantidadeServicosConcluidos,
    'servicos_oferecidos': servicosOferecidos.map((s) => s.toJson()).toList(),
    'selos': selos.map((s) => s.toJson()).toList(),
    'media_avaliacao': mediaAvaliacao,
    'quantidade_avaliacoes': quantidadeAvaliacoes,
    'comentarios': comentarios.map((c) => c.toJson()).toList(),
    'media_avaliacao_servicos': mediaAvaliacaoServicos,
    'quantidade_avaliacoes_servicos': quantidadeAvaliacoesServicos,
    'comentarios_servicos': comentariosServicos.map((c) => c.toJson()).toList(),
  };
}
