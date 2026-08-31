import 'dart:io';
import 'package:backend/src/services/sessao_service.dart';

import 'ws_connection.dart';
import 'ws_router.dart';

class WsServer {
  final WsRouter _router;
  final SessaoService _sessaoService;

  WsServer(this._router, this._sessaoService);

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
    print('Novo cliente conectado');

    conexao.mensagens.listen(
      (msg) => _router.rotear(conexao, msg),
      onDone: () {
        print('Cliente desconectou');
        _sessaoService.remover(conexao);
      },
      onError: (Object erro) {
        print('Erro no socket: $erro');
        _sessaoService.remover(conexao);
      },
    );
  }
}
