import 'package:backend/src/supabase/supabase_client_factory.dart';
import 'package:backend/src/repositories/auth_repository.dart';
import 'package:backend/src/services/sessao_service.dart';
import 'package:backend/src/services/auth_service.dart';
import 'package:backend/src/handlers/auth_handler.dart';
import 'package:backend/src/ws/ws_router.dart';
import 'package:backend/src/ws/ws_server.dart';

Future<void> main() async {
  final supabase = SupabaseClientFactory.criarPublishable();

  final authRepository = AuthRepository(supabase);
  final sessaoService = SessaoService(authRepository);
  final authService = AuthService(authRepository, sessaoService);
  final authHandler = AuthHandler(authService);
  final router = WsRouter(authHandler);
  final server = WsServer(router);

  await server.iniciar();
}
