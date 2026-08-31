import 'dart:async';
import 'package:supabase/supabase.dart';
import '../repositories/auth_repository.dart';
import '../ws/ws_connection.dart';

class SessaoAtiva {
  String userId;
  String accessToken;
  String refreshToken;
  DateTime expiraEm;
  Timer? timerRefresh;

  SessaoAtiva({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiraEm,
  });
}

class SessaoService {
  final AuthRepository _authRepository;
  final Map<WsConnection, SessaoAtiva> _sessoes = {};

  void Function(WsConnection conexao)? onSessaoExpirada;

  SessaoService(this._authRepository);

  void criarSessao(WsConnection conexao, String userId, Session session) {
    _sessoes[conexao]?.timerRefresh?.cancel();

    final sessao = SessaoAtiva(
      userId: userId,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken!,
      expiraEm: DateTime.now().add(
        Duration(seconds: session.expiresIn ?? 3600),
      ),
    );

    _sessoes[conexao] = sessao;
    _agendarRefresh(conexao);
  }

  String? userIdDe(WsConnection conexao) => _sessoes[conexao]?.userId;

  void remover(WsConnection conexao) {
    _sessoes[conexao]?.timerRefresh?.cancel();
    _sessoes.remove(conexao);
  }

  void _agendarRefresh(WsConnection conexao) {
    final sessao = _sessoes[conexao];
    if (sessao == null) return;

    final delay =
        sessao.expiraEm.difference(DateTime.now()) - const Duration(minutes: 5);
    sessao.timerRefresh = Timer(
      delay.isNegative ? Duration.zero : delay,
      () => _renovar(conexao),
    );
  }

  Future<void> _renovar(WsConnection conexao) async {
    final sessao = _sessoes[conexao];
    if (sessao == null) return;

    try {
      final response = await _authRepository.refresh(sessao.refreshToken);
      final session = response.session;
      if (session == null) throw Exception('sessão nula no refresh');

      sessao.accessToken = session.accessToken;
      sessao.refreshToken = session.refreshToken!;
      sessao.expiraEm = DateTime.now().add(
        Duration(seconds: session.expiresIn ?? 3600),
      );

      _agendarRefresh(conexao);
    } catch (_) {
      remover(conexao);
      onSessaoExpirada?.call(conexao);
    }
  }
}
