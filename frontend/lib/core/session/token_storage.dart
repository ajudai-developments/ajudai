import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persiste o refresh_token da sessão do Supabase no armazenamento
/// seguro do dispositivo, pra sobreviver a um fechamento/reinício do
/// app sem exigir login de novo.
///
/// Guarda só o refresh_token — nada de Usuario nem access_token aqui.
/// O access_token é de curta duração e os dados do usuário são
/// reobtidos a cada boot via `restaurarSessao` (ver AuthRepository),
/// então não há necessidade (nem seria seguro) cachear mais que isso.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _chaveRefreshToken = 'refresh_token';

  final _storage = const FlutterSecureStorage();

  Future<void> salvar(String refreshToken) {
    return _storage.write(key: _chaveRefreshToken, value: refreshToken);
  }

  Future<String?> obter() {
    return _storage.read(key: _chaveRefreshToken);
  }

  Future<void> limpar() {
    return _storage.delete(key: _chaveRefreshToken);
  }
}
