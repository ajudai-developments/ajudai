import 'dart:convert';
import 'dart:io';
import 'package:shared/shared.dart';

class WsConnection {
  final WebSocket _socket;

  WsConnection(this._socket);

  void enviar(WsMessage mensagem) {
    _socket.add(jsonEncode(mensagem.toJson()));
  }

  Stream<String> get mensagensCruas => _socket.cast<String>();
}
