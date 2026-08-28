import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:backend/supabase_client.dart';
import 'package:supabase/supabase.dart';

final Map<WebSocket, SessaoSocket> _sessoes = {};

class SessaoSocket {
  String userId;
  String accessToken;
  String refreshToken;
  DateTime expiraEm;
  Timer? timerRefresh;

  SessaoSocket({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiraEm,
  });
}

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Servidor WebSocket rodando em ws://localhost:8080');

  await for (final request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      _handleConexao(socket);
    } else {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..write('Somente WebSocket aqui')
        ..close();
    }
  }
}

void _handleConexao(WebSocket socket) {
  print('Novo cliente conectado');

  socket.listen(
    (dynamic mensagemBruta) async {
      final Map<String, dynamic> msg = jsonDecode(mensagemBruta);
      await _handleMensagem(socket, msg);
    },
    onDone: () => _limparSessao(socket),
    onError: (Object erro) {
      print('Erro no socket: $erro');
      _limparSessao(socket);
    },
  );
}

void _limparSessao(WebSocket socket) {
  _sessoes[socket]?.timerRefresh?.cancel();
  _sessoes.remove(socket);
  print("Sessão removida");
}

Future<void> _handleMensagem(WebSocket socket, Map<String, dynamic> msg) async {
  final tipo = msg['tipo'];

  switch (tipo) {
    case 'login':
      await _handleLogin(socket, msg);
      break;

    case 'cadastro':
      await _handleCadastro(socket, msg);
      break;

    case 'ping':
      final sessao = _sessoes[socket];
      if (sessao == null) {
        _enviarErro(socket, 'Não autenticado');
        return;
      }
      socket.add(jsonEncode({'tipo': 'pong', 'userId': sessao.userId}));
      break;

    default:
      _enviarErro(socket, 'Tipo de mensagem desconhecido: $tipo');
  }
}

Future<void> _handleLogin(WebSocket socket, Map<String, dynamic> msg) async {
  final email = msg['email'];
  final senha = msg['senha'];

  try {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: senha,
    );

    final userId = response.user?.id;
    final session = response.session;
    if (userId == null || session == null) {
      _enviarErro(socket, 'Login falhou');
      return;
    }

    _criarOuAtualizarSessao(socket, userId, session);

    socket.add(jsonEncode({'tipo': 'login_ok', 'userId': userId}));

    print('Usuário $userId autenticado no socket');
  } catch (e) {
    _enviarErro(socket, 'Erro no login: $e');
  }
}

void _criarOuAtualizarSessao(WebSocket socket, String userId, Session session) {
  _sessoes[socket]?.timerRefresh?.cancel();

  final expiraEm = DateTime.fromMicrosecondsSinceEpoch(
    (session.expiresAt ?? 0) * 1000,
  );

  final sessao = SessaoSocket(
    userId: userId,
    accessToken: session.accessToken,
    refreshToken: session.refreshToken!,
    expiraEm: expiraEm,
  );

  _sessoes[socket] = sessao;
  _agendarRefresh(socket);
}

void _agendarRefresh(WebSocket socket) {
  final sessao = _sessoes[socket];
  if (sessao == null) return;

  final tempoAteRenovar =
      sessao.expiraEm.difference(DateTime.now()) - const Duration(minutes: 5);

  final delay = tempoAteRenovar.isNegative ? Duration.zero : tempoAteRenovar;
  sessao.timerRefresh = Timer(delay, () => _renovarSessao(socket));
}

Future<void> _renovarSessao(WebSocket socket) async {
  final sessao = _sessoes[socket];
  if (sessao == null) return;

  try {
    final response = await supabase.auth.refreshSession(sessao.refreshToken);
    final session = response.session;

    if (session == null) {
      _enviarErro(socket, "Sessão expirou, faça login novamente!");
      _limparSessao(socket);
      return;
    }

    sessao.accessToken = session.accessToken;
    sessao.refreshToken = session.refreshToken!;
    sessao.expiraEm = DateTime.fromMillisecondsSinceEpoch(
      (session.expiresAt ?? 0) * 1000,
    );

    print("Sessão renovada automaticamente pro usuário ${sessao.userId}");
    _agendarRefresh(socket);
  } on AuthException catch (e) {
    print("Refresh falhou pro usuário [${sessao.userId}]: ${e.message}");
    _enviarErro(socket, "Sessão expirou, faça login novamente");
    _limparSessao(socket);
  } catch (e) {
    print("Erro ao ao renovar sessão do usuário [${sessao.userId}]");
    _enviarErro(socket, "Erro ao renovar sessão.");
    _limparSessao(socket);
  }
}

Future<void> _handleCadastro(WebSocket socket, Map<String, dynamic> msg) async {
  final email = msg['email'];
  final senha = msg['senha'];
  final telefone = msg['telefone'];
  final cpf = msg["cpf"];
  final nome = msg["nome"];

  try {
    final response = await supabase.auth.signUp(
      email: email,
      password: senha,
      data: {'nome': nome, 'cpf': cpf, 'telefone': telefone},
    );

    final userId = response.user?.id;
    if (userId == null) {
      _enviarErro(socket, 'Cadastro falhou');
      return;
    }

    socket.add(
      jsonEncode({
        'tipo': 'cadastro_ok',
        'userId': userId,
        'access_token': response.session?.accessToken,
        'refresh_token': response.session?.refreshToken,
      }),
    );

    print('Usuário $userId cadastrado');
  } catch (e) {
    _enviarErro(socket, 'Erro no cadastro: $e');
  }
}

void _enviarErro(WebSocket socket, String mensagem) {
  socket.add(jsonEncode({'tipo': 'erro', 'mensagem': mensagem}));
}
