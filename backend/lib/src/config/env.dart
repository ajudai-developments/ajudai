import 'package:dotenv/dotenv.dart';

class Env {
  static final _env = DotEnv(includePlatformEnvironment: true)..load();

  static String get supabaseUrl => _env['SUPABASE_URL']!;
  static String get supabasePublishableKey => _env['SUPABASE_PUBLISHABLE_KEY']!;
  static String get supabaseSecretKey => _env['SECRET_KEY'] ?? '';
}
