import 'package:shared/shared.dart';
import '../services/auth_service.dart';
import '../ws/ws_connection.dart';

class AuthHandler {
  final AuthService _authService;

  AuthHandler(this._authService);

  Future<void> handleLogin(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = LoginRequestDto.fromJson(msg);
      final resposta = await _authService.login(conexao, dto);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.erroInterno, mensagem: e.toString()),
      );
    }
  }

  Future<void> handleCadastro(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = CadastroRequestDto.fromJson(msg);
      final resposta = await _authService.cadastrar(conexao, dto);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.erroInterno, mensagem: e.toString()),
      );
    }
  }
}
