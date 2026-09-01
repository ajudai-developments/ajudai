enum TipoMensagem {
  login('login'),
  loginOk('login_ok'),
  cadastro('cadastro'),
  cadastroOk('cadastro_ok'),
  atualizarPerfil('atualizar_perfil'),
  atualizarPerfilOk('atualizar_perfil_ok'),
  cadastrarEndereco('cadastrar_endereco'),
  cadastrarEnderecoOk('cadastrar_endereco_ok'),
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
