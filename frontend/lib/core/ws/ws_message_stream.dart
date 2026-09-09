import 'dart:async';

import 'package:shared/shared.dart';

class WsErroException implements Exception {
  final ErroCodigo codigo;
  final String mensagem;
  WsErroException({required this.codigo, required this.mensagem});
  @override
  String toString() => 'WsErroException($codigo): $mensagem';
}

class WsTimeoutException implements Exception {
  final TipoMensagem esperado;
  WsTimeoutException(this.esperado);
  @override
  String toString() => 'WsTimeoutException: sem resposta para '
      '"${esperado.valor}" dentro do tempo limite.';
}

class WsMessageStream {
  WsMessageStream._();
  static final WsMessageStream instance = WsMessageStream._();

  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void add(Map<String, dynamic> json) => _controller.add(json);

  Future<Map<String, dynamic>> aguardar(
    TipoMensagem tipo, {
    Duration timeout = const Duration(seconds: 15),
  }) {
    final completer = Completer<Map<String, dynamic>>();
    late final StreamSubscription<Map<String, dynamic>> sub;

    sub = _controller.stream.listen((json) {
      final tipoRecebido = TipoMensagem.fromValor(json['tipo'] as String?);

      if (tipoRecebido == tipo) {
        if (!completer.isCompleted) completer.complete(json);
        sub.cancel();
      } else if (tipoRecebido == TipoMensagem.erro) {
        if (!completer.isCompleted) {
          completer.completeError(
            WsErroException(
              codigo: ErroCodigo.values.firstWhere(
                (e) => e.name == json['codigo'],
                orElse: () => ErroCodigo.erroInterno,
              ),
              mensagem: json['mensagem'] as String? ?? 'Erro desconhecido.',
            ),
          );
        }
        sub.cancel();
      }
    });

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        sub.cancel();
        throw WsTimeoutException(tipo);
      },
    );
  }
}