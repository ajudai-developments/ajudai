import '../handlers/auth_handler.dart';
import 'ws_connection.dart';

class WsRouter {
  final AuthHandler _authHandler;

  WsRouter(this._authHandler);

  Future<void> rotear(WsConnection conexao, Map<String, dynamic> msg) async {
    final tipo = msg['tipo'];

    switch (tipo) {
      case 'login':
        await _authHandler.handleLogin(conexao, msg);
        break;
      case 'cadastro':
        await _authHandler.handleCadastro(conexao, msg);
        break;
      default:
        break;
    }
  }
}
