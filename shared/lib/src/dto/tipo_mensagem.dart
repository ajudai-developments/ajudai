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
