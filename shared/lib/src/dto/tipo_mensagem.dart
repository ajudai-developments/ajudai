enum TipoMensagem {
  login('login'),
  loginOk('login_ok'),
  cadastro('cadastro'),
  cadastroOk('cadastro_ok'),
  atualizarPerfil('atualizar_perfil'),
  atualizarPerfilOk('atualizar_perfil_ok'),
  consultarCep('consultar_cep'),
  consultarCepOk('consultar_cep_ok'),
  criarEndereco('criar_endereco'),
  criarEnderecoOk('criar_endereco_ok'),
  obterMeusEnderecos('obter_meus_enderecos'),
  obterMeusEnderecosOk('obter_meus_endereco_ok'),
  editarEndereco('editar_endereco'),
  editarEnderecoOk('editar_endereco_ok'),
  aprovarPrestador('aprovar_prestador'),
  aprovarPrestadorOk('aprovar_prestador_ok'),
  rejeitarPrestador('rejeitar_prestador'),
  rejeitarPrestadorOk('rejeitar_prestador_ok'),
  listarCategorias('listar_categorias'),
  listarCategoriasOk('listar_categorias_ok'),
  listarServicos('listar_servicos'),
  listarServicosOk('listar_servicos_ok'),
  criarServicoOferecido('criar_servico_oferecido'),
  criarServicoOferecidoOk('criar_servico_oferecido_ok'),
  listarMeusServicosOferecidos('listar_meus_servicos_oferecidos'),
  listarMeusServicosOferecidosOk('listar_meus_servicos_oferecidos_ok'),
  solicitarPrestador('solicitar_prestador'),
  solicitarPrestadorOk('solicitar_prestador_ok'),

  listarVerificacoes('listar_verificacoes'),
  listarVerificacoesOk('listar_verificacoesOk'),

  listarServicosOferecidos('listar_servicos_oferecidos'),
  listarServicosOferecidosOk('listar_servicos_oferecidos_ok'),

  obterServicoOferecido('obter_servico_oferecido'),
  obterServicoOferecidoOk('obter_servico_oferecido_ok'),

  criarAgendamento('criar_agendamento'),
  criarAgendamentoOk('criar_agendamento_ok'),

  confirmarPagamento('confirmar_pagamento'),
  confirmarPagamentoOk('confirmar_pagamento_ok'),

  notificacao('notificacao'),

  responderAgendamento('responder_agendamento'),
  responderAgendamentoOk('responder_agendamento_ok'),
  iniciarAgendamento('iniciar_agendamento'),
  iniciarAgendamentoOk('iniciar_agendamento_ok'),
  concluirAgendamento('concluir_agendamento'),
  concluirAgendamentoOk('concluir_agendamento_ok'),
  confirmarConclusaoAgendamento('confirmar_conclusao_agendamento'),
  confirmarConclusaoAgendamentoOk('confirmar_conclusao_agendamento_ok'),
  cancelarAgendamento('cancelar_agendamento'),
  cancelarAgendamentoOk('cancelar_agendamento_ok'),
  obterAgendamento('obter_agendamento'),
  obterAgendamentoOk('obter_agendamento_ok'),
  listarMeusAgendamentos('listar_meus_agendamentos'),
  listarMeusAgendamentosOk('listar_meus_agendamentos_ok'),
  listarAgendamentosRecebidos('listar_agendamentos_recebidos'),
  listarAgendamentosRecebidosOk('listar_agendamentos_recebidos_ok'),

  erro('erro');

  final String valor;
  const TipoMensagem(this.valor);

  static TipoMensagem? fromValor(String? valor) {
    for (final tipo in TipoMensagem.values) {
      if (tipo.valor == valor) return tipo;
    }
    return null;
  }

  @override
  String toString() => valor;
}
