import 'package:backend/src/clients/cep_client.dart';
import 'package:backend/src/handlers/admin_handler.dart';
import 'package:backend/src/handlers/agendamento_handler.dart';
import 'package:backend/src/handlers/endereco_handler.dart';
import 'package:backend/src/handlers/usuario_handler.dart';
import 'package:backend/src/repositories/usuario_repository.dart';
import 'package:backend/src/services/admin_service.dart';
import 'package:backend/src/services/agendamento_service.dart';
import 'package:backend/src/services/endereco_service.dart';
import 'package:backend/src/services/pagamento_service.dart';
import 'package:backend/src/services/usuario_service.dart';
import 'package:backend/src/supabase/supabase_client_factory.dart';
import 'package:backend/src/repositories/auth_repository.dart';
import 'package:backend/src/services/sessao_service.dart';
import 'package:backend/src/services/auth_service.dart';
import 'package:backend/src/handlers/auth_handler.dart';
import 'package:backend/src/ws/ws_router.dart';
import 'package:backend/src/ws/ws_server.dart';
import 'package:shared/shared.dart';

Future<void> main() async {
  final supabase = SupabaseClientFactory.criarPublishable();
  final usuarioRepository = UsuarioRepository(supabase);
  final authRepository = AuthRepository(supabase);
  final sessaoService = SessaoService(authRepository);
  sessaoService.onSessaoExpirada = (conexao) {
    conexao.enviar(
      ErroDto(
        codigo: ErroCodigo.sessaoExpirada,
        mensagem: 'Sessão expirada, faça login novamente',
      ),
    );
  };
  final authService = AuthService(
    authRepository,
    sessaoService,
    usuarioRepository,
  );
  final usuarioService = UsuarioService(sessaoService);
  final enderecoService = EnderecoService(CepClient(), sessaoService);
  final adminService = AdminService(sessaoService);
  final pagamentoService = PagamentoService();
  final agendamentoService = AgendamentoService(
    sessaoService,
    pagamentoService,
  );
  final usuarioHandler = UsuarioHandler(usuarioService);
  final authHandler = AuthHandler(authService);
  final enderecoHandler = EnderecoHandler(enderecoService);
  final adminHandler = AdminHandler(adminService);
  final agendamentoHandler = AgendamentoHandler(agendamentoService);
  final router = WsRouter(
    authHandler,
    usuarioHandler,
    enderecoHandler,
    adminHandler,
    agendamentoHandler,
  );
  final server = WsServer(router, sessaoService);

  await server.iniciar();
}
