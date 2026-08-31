import 'package:backend/src/config/env.dart';
import 'package:supabase/supabase.dart';

class SupabaseClientFactory {
  static SupabaseClient criarPublishable() {
    return SupabaseClient(
      Env.supabaseUrl,
      Env.supabasePublishableKey,
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
  }

  static SupabaseClient criarSecret() {
    return SupabaseClient(
      Env.supabaseUrl,
      Env.supabaseSecretKey,
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
  }

  static SupabaseClient criarComToken(String accessToken) {
    return SupabaseClient(
      Env.supabaseUrl,
      Env.supabasePublishableKey,
      headers: {'Authorization': 'Bearer $accessToken'},
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
  }
}
