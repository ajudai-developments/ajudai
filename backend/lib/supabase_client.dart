import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

final env = DotEnv()..load();

final supabase = SupabaseClient(
  env['SUPABASE_URL']!,
  env["SUPABASE_PUBLISHABLE_KEY"]!,
  authOptions: const AuthClientOptions(
    autoRefreshToken: false,
    authFlowType: AuthFlowType.implicit,
  ),
);
