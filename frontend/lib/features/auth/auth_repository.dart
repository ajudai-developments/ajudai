import 'package:ajudai/core/session/sessao.dart';
import 'package:ajudai/core/session/token_storage.dart';
import 'package:ajudai/core/ws/ws_client.dart';
import 'package:ajudai/core/ws/ws_message_stream.dart';
import 'package:shared/shared.dart';

class AuthRepository {
  Future<Usuario> login({required String email, required String senha}) async {
    await WsClient.instance.conectar();
    WsClient.instance.enviar(LoginRequestDto(email: email, senha: senha));

    final json = await WsMessageStream.instance.aguardar(TipoMensagem.loginOk);
    final resposta = LoginResponseDto.fromJson(json);

    Sessao.instance.definirUsuario(resposta.usuario);
    await TokenStorage.instance.salvar(resposta.refreshToken);
    return resposta.usuario;
  }

  Future<Usuario> cadastrar({
    required String email,
    required String senha,
    required String nome,
    required String cpf,
    String? telefone,
  }) async {
    await WsClient.instance.conectar();
    WsClient.instance.enviar(
      CadastroRequestDto(
        email: email,
        senha: senha,
        nome: nome,
        cpf: cpf,
        telefone: telefone,
      ),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.cadastroOk,
    );
    final resposta = CadastroResponseDto.fromJson(json);

    Sessao.instance.definirUsuario(resposta.usuario);
    await TokenStorage.instance.salvar(resposta.refreshToken);
    return resposta.usuario;
  }

  /// Tenta restaurar uma sessão anterior a partir do refresh_token salvo
  /// no dispositivo (ver TokenStorage). Chamado no boot do app, antes de
  /// mostrar qualquer tela.
  ///
  /// Retorna o Usuario se a sessão foi restaurada com sucesso (e já
  /// popula Sessao.instance e salva o refresh_token rotacionado), ou
  /// `null` se não havia token salvo ou se ele não é mais válido — nesse
  /// caso o token salvo é apagado, pra não ficar tentando de novo em
  /// toda inicialização.
  Future<Usuario?> restaurarSessao() async {
    final refreshToken = await TokenStorage.instance.obter();
    if (refreshToken == null) return null;

    try {
      await WsClient.instance.conectar();
      WsClient.instance.enviar(
        RestaurarSessaoRequestDto(refreshToken: refreshToken),
      );

      final json = await WsMessageStream.instance.aguardar(
        TipoMensagem.restaurarSessaoOk,
      );
      final resposta = RestaurarSessaoResponseDto.fromJson(json);

      Sessao.instance.definirUsuario(resposta.usuario);
      await TokenStorage.instance.salvar(resposta.refreshToken);
      return resposta.usuario;
    } on WsErroException {
      await TokenStorage.instance.limpar();
      return null;
    } on WsTimeoutException {
      return null;
    }
  }

  Future<void> logout() async {
    Sessao.instance.limpar();
    await TokenStorage.instance.limpar();
    await WsClient.instance.desconectar();
  }
}
