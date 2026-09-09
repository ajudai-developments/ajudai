import 'package:backend/src/clients/cep_client.dart';
import 'package:backend/src/handlers/admin_handler.dart';
import 'package:backend/src/handlers/agendamento_handler.dart';
import 'package:backend/src/handlers/avaliacao_handler.dart';
import 'package:backend/src/handlers/categorias_handler.dart';
import 'package:backend/src/handlers/endereco_handler.dart';
import 'package:backend/src/handlers/servico_handler.dart';
import 'package:backend/src/handlers/notificacao_handler.dart';
import 'package:backend/src/handlers/usuario_handler.dart';
import 'package:backend/src/repositories/agendamento_repository.dart';
import 'package:backend/src/repositories/notificacao_repository.dart';
import 'package:backend/src/repositories/usuario_repository.dart';
import 'package:backend/src/services/admin_service.dart';
import 'package:backend/src/services/agendamento_service.dart';
import 'package:backend/src/services/avaliacao_service.dart';
import 'package:backend/src/services/categoria_service.dart';
import 'package:backend/src/services/endereco_service.dart';
import 'package:backend/src/services/eventos_agendamento_listener.dart';
import 'package:backend/src/services/pagamento_service.dart';
import 'package:backend/src/services/servico_service.dart';
import 'package:backend/src/services/usuario_service.dart';
import 'package:backend/src/services/notificacao_service.dart';
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
  final notificacaoRepository = NotificacaoRepository(
    SupabaseClientFactory.criarSecret(),
  );
  final sessaoService = SessaoService(authRepository, notificacaoRepository);
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
  final agendamentoRepositoryParaEventos = AgendamentoRepository(
    SupabaseClientFactory.criarSecret(),
  );

  EventosAgendamentoListener(
    client: SupabaseClientFactory.criarSecret(),
    sessaoService: sessaoService,
    agendamentoRepository: agendamentoRepositoryParaEventos,
  ).iniciar();
  final categoriaService = CategoriaService(sessaoService);
  final servicoService = ServicoService(sessaoService);
  final usuarioHandler = UsuarioHandler(usuarioService);
  final authHandler = AuthHandler(authService);
  final enderecoHandler = EnderecoHandler(enderecoService);
  final adminHandler = AdminHandler(adminService);
  final agendamentoHandler = AgendamentoHandler(agendamentoService);
  final servicoHandler = ServicoHandler(servicoService);
  final categoriaHandler = CategoriaHandler(categoriaService);
  final notificacaoService = NotificacaoService(
    sessaoService,
    notificacaoRepository,
  );
  final avaliacaoService = AvaliacaoService(sessaoService);
  final notificacaoHandler = NotificacaoHandler(notificacaoService);
  final avaliacaoHandler = AvaliacaoHandler(avaliacaoService);
  final router = WsRouter(
    authHandler,
    usuarioHandler,
    enderecoHandler,
    adminHandler,
    agendamentoHandler,
    servicoHandler,
    categoriaHandler,
    notificacaoHandler,
    avaliacaoHandler,
  );
  final server = WsServer(router, sessaoService);

  await server.iniciar();
}
