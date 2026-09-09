import 'package:ajudai/core/session/sessao.dart';
import 'package:ajudai/core/ws/ws_client.dart';
import 'package:ajudai/core/ws/ws_message_stream.dart';
import 'package:shared/shared.dart';

class AuthRepository {
  Future<Usuario> login({required String email, required String senha}) async {
    await WsClient.instance.conectar();
    WsClient.instance.enviar(LoginRequestDto(email: email, senha: senha));

    final json = await WsMessageStream.instance.aguardar(TipoMensagem.loginOk);
    final usuario = LoginResponseDto.fromJson(json).usuario;

    Sessao.instance.definirUsuario(usuario);
    return usuario;
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
      CadastroRequestDto(email: email, senha: senha, nome: nome, cpf: cpf, telefone: telefone),
    );

    final json = await WsMessageStream.instance.aguardar(TipoMensagem.cadastroOk);
    final usuario = CadastroResponseDto.fromJson(json).usuario;

    Sessao.instance.definirUsuario(usuario);
    return usuario;
  }

  Future<void> logout() async {
    Sessao.instance.limpar();
    await WsClient.instance.desconectar();
  }
}