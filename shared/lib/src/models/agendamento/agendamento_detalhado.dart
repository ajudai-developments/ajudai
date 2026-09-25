import 'package:shared/shared.dart';

/// Detalhes completos de um agendamento, do ponto de vista de QUALQUER
/// um dos dois lados (cliente ou prestador). É um model específico
/// dessa tela — não reaproveita `Agendamento`, porque carrega dados que
/// vão muito além dele (serviço, categoria, avaliações, contestação,
/// solicitação de preço, timeline).
///
/// Quem consome decide, com [souCliente]/[souPrestador], quem é "eu" e
/// quem é "a outra pessoa" na tela.
class AgendamentoDetalhado {
  final String id;
  final String usuarioId;
  final String prestadorId;
  final String servicoOferecidoId;
  final String? enderecoId;
  final String enderecoLogradouro;
  final String enderecoNumero;
  final String? enderecoComplemento;
  final String enderecoBairro;
  final String enderecoCidade;
  final String enderecoEstado;
  final String enderecoCep;
  final DateTime horaInicio;
  final DateTime horaFim;
  final double valor;
  final StatusAgendamento status;
  final DateTime criadoEm;
  final DateTime? editadoEm;
  final DateTime? horaInicioReal;
  final DateTime? horaConclusaoPrestador;
  final DateTime? horaConfirmacaoUsuario;

  final String categoriaNome;
  final String servicoNome;
  final String servicoOferecidoDescricao;

  final String clienteId;
  final String clienteNome;
  final String? clienteAvatarUrl;
  final bool clienteVerificado;
  final String? clienteTelefone;

  final String prestadorNome;
  final String? prestadorAvatarUrl;
  final bool prestadorVerificado;
  final String? prestadorTelefone;

  final AvaliacaoResumo? avaliacaoFeitaPorMim;
  final AvaliacaoResumo? avaliacaoRecebidaPorMim;
  final ContestacaoComDetalhes? contestacaoAberta;
  final SolicitacaoPrecoResumo? solicitacaoPrecoPendente;
  final List<TimelineItemAgendamento> timeline;

  AgendamentoDetalhado({
    required this.id,
    required this.usuarioId,
    required this.prestadorId,
    required this.servicoOferecidoId,
    required this.enderecoId,
    required this.enderecoLogradouro,
    required this.enderecoNumero,
    this.enderecoComplemento,
    required this.enderecoBairro,
    required this.enderecoCidade,
    required this.enderecoEstado,
    required this.enderecoCep,
    required this.horaInicio,
    required this.horaFim,
    required this.valor,
    required this.status,
    required this.criadoEm,
    this.editadoEm,
    this.horaInicioReal,
    this.horaConclusaoPrestador,
    this.horaConfirmacaoUsuario,
    required this.categoriaNome,
    required this.servicoNome,
    required this.servicoOferecidoDescricao,
    required this.clienteId,
    required this.clienteNome,
    this.clienteAvatarUrl,
    required this.clienteVerificado,
    this.clienteTelefone,
    required this.prestadorNome,
    this.prestadorAvatarUrl,
    required this.prestadorVerificado,
    this.prestadorTelefone,
    this.avaliacaoFeitaPorMim,
    this.avaliacaoRecebidaPorMim,
    this.contestacaoAberta,
    this.solicitacaoPrecoPendente,
    required this.timeline,
  });

  /// `true` se o usuário informado é quem contratou (o "usuario_id").
  bool souCliente(String meuUsuarioId) => usuarioId == meuUsuarioId;

  /// `true` se o usuário informado é quem prestou o serviço.
  bool souPrestador(String meuUsuarioId) => prestadorId == meuUsuarioId;

  factory AgendamentoDetalhado.fromJson(Map<String, dynamic> json) {
    return AgendamentoDetalhado(
      id: JsonUtils.requireString(json, 'id'),
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
      prestadorId: JsonUtils.requireString(json, 'prestador_id'),
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
      enderecoId: JsonUtils.optionalString(json, 'endereco_id'),
      enderecoLogradouro: JsonUtils.requireString(json, 'endereco_logradouro'),
      enderecoNumero: JsonUtils.requireString(json, 'endereco_numero'),
      enderecoComplemento: JsonUtils.optionalString(
        json,
        'endereco_complemento',
      ),
      enderecoBairro: JsonUtils.requireString(json, 'endereco_bairro'),
      enderecoCidade: JsonUtils.requireString(json, 'endereco_cidade'),
      enderecoEstado: JsonUtils.requireString(json, 'endereco_estado'),
      enderecoCep: JsonUtils.requireString(json, 'endereco_cep'),
      horaInicio: JsonUtils.requireDateTime(json, 'hora_inicio'),
      horaFim: JsonUtils.requireDateTime(json, 'hora_fim'),
      valor: JsonUtils.requireDouble(json, 'valor'),
      status: StatusAgendamento.fromValor(
        JsonUtils.requireString(json, 'status'),
      ),
      criadoEm: JsonUtils.requireDateTime(json, 'criado_em'),
      editadoEm: JsonUtils.optionalDateTime(json, 'editado_em'),
      horaInicioReal: JsonUtils.optionalDateTime(json, 'hora_inicio_real'),
      horaConclusaoPrestador: JsonUtils.optionalDateTime(
        json,
        'hora_conclusao_prestador',
      ),
      horaConfirmacaoUsuario: JsonUtils.optionalDateTime(
        json,
        'hora_confirmacao_usuario',
      ),
      categoriaNome: JsonUtils.requireString(json, 'categoria_nome'),
      servicoNome: JsonUtils.requireString(json, 'servico_nome'),
      servicoOferecidoDescricao: JsonUtils.requireString(
        json,
        'servico_oferecido_descricao',
      ),
      clienteId: JsonUtils.requireString(json, 'cliente_id'),
      clienteNome: JsonUtils.requireString(json, 'cliente_nome'),
      clienteAvatarUrl: JsonUtils.optionalString(json, 'cliente_avatar_url'),
      clienteVerificado: json['cliente_verificado'] as bool,
      clienteTelefone: JsonUtils.optionalString(json, 'cliente_telefone'),
      prestadorNome: JsonUtils.requireString(json, 'prestador_nome'),
      prestadorAvatarUrl: JsonUtils.optionalString(
        json,
        'prestador_avatar_url',
      ),
      prestadorVerificado: json['prestador_verificado'] as bool,
      prestadorTelefone: JsonUtils.optionalString(json, 'prestador_telefone'),
      avaliacaoFeitaPorMim: json['avaliacao_feita_por_mim'] == null
          ? null
          : AvaliacaoResumo.fromJson(
              json['avaliacao_feita_por_mim'] as Map<String, dynamic>,
            ),
      avaliacaoRecebidaPorMim: json['avaliacao_recebida_por_mim'] == null
          ? null
          : AvaliacaoResumo.fromJson(
              json['avaliacao_recebida_por_mim'] as Map<String, dynamic>,
            ),
      contestacaoAberta: json['contestacao_aberta'] == null
          ? null
          : ContestacaoComDetalhes.fromJson(
              json['contestacao_aberta'] as Map<String, dynamic>,
            ),
      solicitacaoPrecoPendente: json['solicitacao_preco_pendente'] == null
          ? null
          : SolicitacaoPrecoResumo.fromJson(
              json['solicitacao_preco_pendente'] as Map<String, dynamic>,
            ),
      timeline: (json['timeline'] as List)
          .map(
            (e) => TimelineItemAgendamento.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'prestador_id': prestadorId,
    'servico_oferecido_id': servicoOferecidoId,
    'endereco_id': enderecoId,
    'endereco_logradouro': enderecoLogradouro,
    'endereco_numero': enderecoNumero,
    'endereco_complemento': enderecoComplemento,
    'endereco_bairro': enderecoBairro,
    'endereco_cidade': enderecoCidade,
    'endereco_estado': enderecoEstado,
    'endereco_cep': enderecoCep,
    'hora_inicio': horaInicio.toIso8601String(),
    'hora_fim': horaFim.toIso8601String(),
    'valor': valor,
    'status': status.valor,
    'criado_em': criadoEm.toIso8601String(),
    'editado_em': editadoEm?.toIso8601String(),
    'hora_inicio_real': horaInicioReal?.toIso8601String(),
    'hora_conclusao_prestador': horaConclusaoPrestador?.toIso8601String(),
    'hora_confirmacao_usuario': horaConfirmacaoUsuario?.toIso8601String(),
    'categoria_nome': categoriaNome,
    'servico_nome': servicoNome,
    'servico_oferecido_descricao': servicoOferecidoDescricao,
    'cliente_id': clienteId,
    'cliente_nome': clienteNome,
    'cliente_avatar_url': clienteAvatarUrl,
    'cliente_verificado': clienteVerificado,
    'cliente_telefone': clienteTelefone,
    'prestador_nome': prestadorNome,
    'prestador_avatar_url': prestadorAvatarUrl,
    'prestador_verificado': prestadorVerificado,
    'prestador_telefone': prestadorTelefone,
    'avaliacao_feita_por_mim': avaliacaoFeitaPorMim?.toJson(),
    'avaliacao_recebida_por_mim': avaliacaoRecebidaPorMim?.toJson(),
    'contestacao_aberta': contestacaoAberta?.toJson(),
    'solicitacao_preco_pendente': solicitacaoPrecoPendente?.toJson(),
    'timeline': timeline.map((e) => e.toJson()).toList(),
  };
}
