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

  obterServicoOferecido('obter_servico_oferecido'),
  obterServicoOferecidoOk('obter_servico_oferecido_ok'),

  listarServicoOferecidoPorCategoria('listar_servico_oferecido_por_categoria'),
  listarServicoOferecidoPorCategoriaOk(
    'listar_servico_oferecido_por_categoria_ok',
  ),

  listarServicoOferecidoPorPrestador('listar_servico_oferecido_por_prestador'),
  listarServicoOferecidoPorPrestadorOk(
    'listar_servico_oferecido_por_prestador_ok',
  ),

  listarServicoOferecidoPorServico('listar_servico_oferecido_por_servico'),
  listarServicoOferecidoPorServicoOk('listar_servico_oferecido_por_servico_ok'),

  editarServicoOferecido('editar_servico_oferecido'),
  editarServicoOferecidoOk('editar_servico_oferecido_ok'),

  desativarServicoOferecido('desativar_servico_oferecido'),
  desativarServicoOferecidoOk('desativar_servico_oferecido_ok'),

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

  obterAgendamentoCliente('obter_agendamento_cliente'),
  obterAgendamentoClienteOk('obter_agendamento_cliente_ok'),
  obterAgendamentoPrestador('obter_agendamento_prestador'),
  obterAgendamentoPrestadorOk('obter_agendamento_prestador_ok'),

  listarAgendamentosCliente('listar_agendamentos_cliente'),
  listarAgendamentosClienteOk('listar_agendamentos_cliente_ok'),
  listarAgendamentosPrestador('listar_agendamentos_prestador'),
  listarAgendamentosPrestadorOk('listar_agendamentos_prestador_ok'),

  listarAgendamentosRecebidos('listar_agendamentos_recebidos'),
  listarAgendamentosRecebidosOk('listar_agendamentos_recebidos_ok'),

  listarNotificacoes('listar_notificacoes'),
  listarNotificacoesOk('listar_notificacoes_ok'),

  avaliarAgendamento('avaliar_agendamento'),
  avaliarAgendamentoOk('avaliar_agendamento_ok'),

  avaliarUsuario('avaliar_usuario'),
  avaliarUsuarioOk('avaliar_usuario_ok'),

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
