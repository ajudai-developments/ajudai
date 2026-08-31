import 'package:backend/src/handlers/usuario_handler.dart';
import 'package:shared/shared.dart';
import '../handlers/auth_handler.dart';
import 'ws_connection.dart';

class WsRouter {
  final AuthHandler _authHandler;
  final UsuarioHandler _usuarioHandler;
  WsRouter(this._authHandler, this._usuarioHandler);

  Future<void> rotear(WsConnection conexao, Map<String, dynamic> msg) async {
    final tipo = msg['tipo'];

    switch (tipo) {
      case 'login':
        await _authHandler.handleLogin(conexao, msg);
        break;
      case 'cadastro':
        await _authHandler.handleCadastro(conexao, msg);
        break;

      case 'atualizar_perfil':
        await _usuarioHandler.handleAtualizarPerfil(conexao, msg);
      default:
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.dadosInvalidos,
            mensagem: 'Tipo de mensagem desconhecido: $tipo',
          ),
        );
    }
  }
}
