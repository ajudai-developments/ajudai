import 'dart:async';
import 'dart:convert';

import 'package:ajudai/core/config/env.dart';
import 'package:shared/shared.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'ws_message_stream.dart';

/// Cliente WebSocket único do app.
///
/// Responsabilidades:
/// - abrir/fechar a conexão com o backend;
/// - serializar e enviar qualquer WsMessage (DTO do pacote `shared`);
/// - desserializar cada mensagem recebida e repassar para o
///   WsMessageStream, que é quem os repositórios de cada feature escutam.
///
/// Esta classe NÃO sabe nada sobre DTOs específicos (login, agendamento,
/// etc) — isso é responsabilidade de cada `*_repository.dart`. O WsClient
/// só fala Map<String, dynamic> pra fora e WsMessage pra dentro.
///
/// Depende do pacote `web_socket_channel` (funciona em mobile e web,
/// diferente de dart:io WebSocket). Adicionar em pubspec.yaml:
///   web_socket_channel: ^3.0.0
class WsClient {
  WsClient._();
  static final WsClient instance = WsClient._();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  bool get conectado => _channel != null;

  /// Completa quando a conexão cai (fecha ou dá erro), para quem quiser
  /// reagir (ex: mostrar tela de "sem conexão", tentar reconectar).
  final StreamController<void> _onDesconectado =
      StreamController<void>.broadcast();
  Stream<void> get onDesconectado => _onDesconectado.stream;

  Future<void> conectar({String url = Env.wsUrl}) async {
    if (conectado) return;

    final channel = WebSocketChannel.connect(Uri.parse(url));
    await channel.ready; // lança se o handshake falhar

    _channel = channel;
    _subscription = channel.stream.listen(
      _onMensagemRecebida,
      onError: (_) => _tratarDesconexao(),
      onDone: _tratarDesconexao,
    );
  }

  void _onMensagemRecebida(dynamic raw) {
    if (raw is! String) return;

    late final Map<String, dynamic> json;
    try {
      json = jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      // Mensagem inválida vinda do servidor: ignora em vez de derrubar o app.
      return;
    }

    WsMessageStream.instance.add(json);
  }

  void _tratarDesconexao() {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _onDesconectado.add(null);
  }

  /// Serializa e envia um WsMessage. Lança StateError se não houver
  /// conexão ativa — quem chama deve ter garantido `conectado == true`
  /// (ou chamar `conectar()` antes).
  void enviar(WsMessage mensagem) {
    final channel = _channel;
    if (channel == null) {
      throw StateError(
        'Tentativa de enviar "${mensagem.tipo.valor}" sem conexão ativa.',
      );
    }
    channel.sink.add(jsonEncode(mensagem.toJson()));
  }

  Future<void> desconectar() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    _subscription = null;
    _channel = null;
  }
}
