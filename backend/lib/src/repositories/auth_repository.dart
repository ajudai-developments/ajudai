import 'package:supabase/supabase.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Future<AuthResponse> login({required String email, required String senha}) {
    return _client.auth.signInWithPassword(email: email, password: senha);
  }

  Future<AuthResponse> cadastrar({
    required String email,
    required String senha,
    required Map<String, dynamic> metadata,
  }) {
    return _client.auth.signUp(email: email, password: senha, data: metadata);
  }

  Future<AuthResponse> refresh(String refreshToken) {
    return _client.auth.refreshSession(refreshToken);
  }
}
