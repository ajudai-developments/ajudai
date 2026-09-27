import 'dart:async';
import 'dart:convert';
import 'dart:math';

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
///   WsMessageStream, que é quem os repositórios de cada feature escutam;
/// - reconectar sozinho quando a conexão cai por motivo alheio ao
///   usuário (queda de rede, app voltou do background, servidor
///   reiniciou etc.) e, uma vez reconectado, restaurar a sessão via o
///   callback configurado em [aoRestaurarSessao] — sem exigir que o
///   usuário reabra o app.
///
/// Esta classe NÃO sabe nada sobre DTOs específicos (login, agendamento,
/// etc) — isso é responsabilidade de cada `*_repository.dart`. O WsClient
/// só fala Map<String, dynamic> pra fora e WsMessage pra dentro. Pelo
/// mesmo motivo, ele também não conhece `AuthRepository` diretamente
/// (evita dependência circular entre core/ws e as camadas de sessão) —
/// quem sabe restaurar sessão é injetado de fora via [aoRestaurarSessao].
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

  /// `true` enquanto uma tentativa de reconexão automática está em
  /// andamento — útil pra UI mostrar um banner de "reconectando...".
  bool _reconectando = false;
  bool get reconectando => _reconectando;

  /// `true` só quando a desconexão foi pedida explicitamente (logout).
  /// Nesse caso não tentamos reconectar sozinhos.
  bool _desconexaoManual = false;

  Timer? _timerReconexao;
  int _tentativasReconexao = 0;
  static const _backoffMaximo = Duration(seconds: 30);

  /// Callback configurado uma vez no bootstrap do app (ver main.dart)
  /// apontando pra `AuthRepository().restaurarSessao()`. É chamado
  /// automaticamente toda vez que a reconexão automática tem sucesso.
  Future<void> Function()? _aoRestaurarSessao;

  void aoRestaurarSessao(Future<void> Function() callback) {
    _aoRestaurarSessao = callback;
  }

  /// Completa a cada desconexão (fecha ou dá erro), para quem quiser
  /// reagir (ex: mostrar tela de "sem conexão"). Emite de novo quando a
  /// reconexão automática tiver sucesso — ver [onReconectado].
  final StreamController<void> _onDesconectado =
      StreamController<void>.broadcast();
  Stream<void> get onDesconectado => _onDesconectado.stream;

  final StreamController<void> _onReconectado =
      StreamController<void>.broadcast();
  Stream<void> get onReconectado => _onReconectado.stream;

  Future<void> conectar({String url = Env.wsUrl}) async {
    if (conectado) return;

    final channel = WebSocketChannel.connect(Uri.parse(url));
    await channel.ready; // lança se o handshake falhar

    _channel = channel;
    _desconexaoManual = false;
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

    if (_desconexaoManual) return; // logout — não reconecta sozinho
    _agendarReconexao();
  }

  /// Tenta reconectar com backoff exponencial (2s, 4s, 8s, 16s, capado
  /// em 30s) até dar certo. Ignorado se já houver uma tentativa em
  /// andamento (evita loops duplicados se `_tratarDesconexao` disparar
  /// mais de uma vez seguida).
  void _agendarReconexao() {
    if (_reconectando) return;
    _reconectando = true;
    _tentativasReconexao = 0;
    _tentarReconectar();
  }

  void _tentarReconectar() {
    final espera = Duration(
      seconds: min(2 << _tentativasReconexao, _backoffMaximo.inSeconds),
    );
    _tentativasReconexao++;

    _timerReconexao = Timer(espera, () async {
      if (_desconexaoManual) {
        _reconectando = false;
        return;
      }

      try {
        await conectar();
        _reconectando = false;
        _tentativasReconexao = 0;
        _onReconectado.add(null);
        await _aoRestaurarSessao?.call();
      } catch (_) {
        // Ainda sem rede/servidor indisponível — tenta de novo.
        _tentarReconectar();
      }
    });
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

  /// Desconexão EXPLÍCITA (logout) — cancela qualquer reconexão
  /// automática agendada, diferente de uma queda de conexão espontânea.
  Future<void> desconectar() async {
    _desconexaoManual = true;
    _timerReconexao?.cancel();
    _timerReconexao = null;
    _reconectando = false;

    await _subscription?.cancel();
    await _channel?.sink.close();
    _subscription = null;
    _channel = null;
  }
}
