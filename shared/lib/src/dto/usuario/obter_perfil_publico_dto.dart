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

  ObterPerfilPublicoResponseDto({
    required this.usuario,
    required this.ehPrestador,
    required this.quantidadeServicosConcluidos,
    required this.servicosOferecidos,
    required this.selos,
    this.mediaAvaliacao,
    required this.quantidadeAvaliacoes,
    required this.comentarios,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.obterPerfilPublicoOk;

  factory ObterPerfilPublicoResponseDto.fromJson(Map<String, dynamic> json) {
    final servicos = JsonUtils.requireListaDeMapas(json, 'servicos_oferecidos');
    final selos = JsonUtils.requireListaDeMapas(json, 'selos');
    final comentarios = JsonUtils.requireListaDeMapas(json, 'comentarios');

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
  };
}
