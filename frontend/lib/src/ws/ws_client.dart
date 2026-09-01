import 'dart:async';
import 'dart:convert';

import 'package:shared/shared.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Erro retornado pelo back-end via mensagem do tipo `erro`.
class WsErrorException implements Exception {
  final String mensagem;
  WsErrorException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Envelope simples para uma conexão WebSocket com o back-end.
///
/// Responsável por: conectar, (re)enviar [WsMessage]s e expor um stream
/// de mensagens decodificadas (Map) para quem quiser escutar.
class WsClient {
  final Uri url;
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _mensagensController;

  WsClient({required this.url});

  Stream<Map<String, dynamic>> get mensagens =>
      _mensagensController?.stream ?? const Stream.empty();

  bool get conectado => _channel != null;

  Future<void> conectar() async {
    if (conectado) return;

    _mensagensController = StreamController<Map<String, dynamic>>.broadcast();
    _channel = WebSocketChannel.connect(url);

    _channel!.stream.listen(
      (dynamic evento) {
        final decodificado =
            jsonDecode(evento as String) as Map<String, dynamic>;
        _mensagensController?.add(decodificado);
      },
      onError: (Object erro) {
        _mensagensController?.addError(erro);
      },
      onDone: () {
        _channel = null;
      },
    );

    await _channel!.ready;
  }

  void enviar(WsMessage mensagem) {
    if (!conectado) {
      throw StateError('WsClient não está conectado.');
    }
    _channel!.sink.add(jsonEncode(mensagem.toJson()));
  }

  /// Envia [mensagem] e aguarda a primeira resposta cujo campo `tipo`
  /// esteja em [tiposEsperados], ou lança [WsErrorException] se o
  /// back-end responder com `erro`.
  Future<Map<String, dynamic>> enviarEAguardar(
    WsMessage mensagem, {
    required Set<String> tiposEsperados,
    Duration timeout = const Duration(seconds: 12),
  }) async {
    if (!conectado) {
      await conectar();
    }

    final completer = Completer<Map<String, dynamic>>();
    late final StreamSubscription<Map<String, dynamic>> sub;

    sub = mensagens.listen((msg) {
      final tipo = msg['tipo'] as String?;
      if (tipo == 'erro') {
        final erroMsg =
            (msg['mensagem'] ?? msg['erro'] ?? 'Erro desconhecido no servidor')
                .toString();
        if (!completer.isCompleted) {
          completer.completeError(WsErrorException(erroMsg));
        }
      } else if (tipo != null && tiposEsperados.contains(tipo)) {
        if (!completer.isCompleted) completer.complete(msg);
      }
    });

    enviar(mensagem);

    try {
      return await completer.future.timeout(
        timeout,
        onTimeout: () =>
            throw WsErrorException('Tempo de resposta do servidor esgotado.'),
      );
    } finally {
      await sub.cancel();
    }
  }

  Future<void> desconectar() async {
    await _channel?.sink.close();
    await _mensagensController?.close();
    _channel = null;
    _mensagensController = null;
  }
}
