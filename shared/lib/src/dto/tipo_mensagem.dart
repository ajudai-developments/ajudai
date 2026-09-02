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
  seTornarPrestador('se_tornar_prestador'),
  seTornarPrestadorOk('se_tornar_prestador_ok'),
  aprovarPrestador('aprovar_prestador'),
  aprovarPrestadorOk('aprovar_prestador_ok'),
  rejeitarPrestador('rejeitar_prestador'),
  rejeitarPrestadorOk('rejeitar_prestador_ok'),
  listarCategoriasOk('listar_categorias_ok'),
  listarServicos('listar_servicos'),
  listarServicosOk('listar_servicos_ok'),
  criarServicoOferecido('criar_servico_oferecido'),
  criarServicoOferecidoOk('criar_servico_oferecido_ok'),
  solicitarPrestador('solicitar_prestador'),
  solicitarPrestadorOk('solicitar_prestador_ok'),

  listarVerificacoes('listar_verificacoes'),
  listarVerificacoesOk('listar_verificacoesOk'),

  listarServicosOferecidosOk('listar_servicos_oferecidos_ok'),

  obterServicoOferecido('obter_servico_oferecido'),
  obterServicoOferecidoOk('obter_servico_oferecido_ok'),

  criarAgendamento('criar_agendamento'),
  criarAgendamentoOk('criar_agendamento_ok'),

  confirmarPagamento('confirmar_pagamento'),
  confirmarPagamentoOk('confirmar_pagamento_ok'),
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
