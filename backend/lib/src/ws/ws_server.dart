import 'dart:io';
import 'ws_connection.dart';
import 'ws_router.dart';

class WsServer {
  final WsRouter _router;

  WsServer(this._router);

  Future<void> iniciar({int porta = 8080}) async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, porta);
    print('Servidor WebSocket rodando em ws://localhost:$porta');

    await for (final request in server) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        final socket = await WebSocketTransformer.upgrade(request);
        _handleConexao(WsConnection(socket));
      } else {
        request.response
          ..statusCode = HttpStatus.forbidden
          ..close();
      }
    }
  }

  void _handleConexao(WsConnection conexao) {
    conexao.mensagens.listen(
      (msg) => _router.rotear(conexao, msg),
      onDone: () {},
      onError: (_) {},
    );
  }
}
