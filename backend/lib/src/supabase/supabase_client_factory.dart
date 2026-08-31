import 'package:backend/src/config/env.dart';
import 'package:supabase/supabase.dart';

class SupabaseClientFactory {
  static SupabaseClient criarPublishable() {
    return SupabaseClient(Env.supabaseUrl, Env.supabasePublishableKey);
  }

  static SupabaseClient criarSecret() {
    return SupabaseClient(Env.supabaseUrl, Env.supabaseSecretKey);
  }
}
