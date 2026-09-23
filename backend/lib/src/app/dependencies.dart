import 'package:backend/src/app/app_handlers.dart';
import 'package:backend/src/clients/cep_client.dart';
import 'package:backend/src/handlers/admin_handler.dart';
import 'package:backend/src/handlers/agendamento_handler.dart';
import 'package:backend/src/handlers/auth_handler.dart';
import 'package:backend/src/handlers/avaliacao_handler.dart';
import 'package:backend/src/handlers/categorias_handler.dart';
import 'package:backend/src/handlers/chat_handler.dart';
import 'package:backend/src/handlers/contestacao_handler.dart';
import 'package:backend/src/handlers/denuncia_handler.dart';
import 'package:backend/src/handlers/endereco_handler.dart';
import 'package:backend/src/handlers/notificacao_handler.dart';
import 'package:backend/src/handlers/servico_handler.dart';
import 'package:backend/src/handlers/usuario_handler.dart';
import 'package:backend/src/repositories/agendamento_repository.dart';
import 'package:backend/src/repositories/auth_repository.dart';
import 'package:backend/src/repositories/notificacao_repository.dart';
import 'package:backend/src/repositories/servico_repository.dart';
import 'package:backend/src/repositories/usuario_repository.dart';
import 'package:backend/src/services/admin_service.dart';
import 'package:backend/src/services/agendamento_service.dart';
import 'package:backend/src/services/auth_service.dart';
import 'package:backend/src/services/avaliacao_service.dart';
import 'package:backend/src/services/categoria_service.dart';
import 'package:backend/src/services/chat_service.dart';
import 'package:backend/src/services/conquista_listener.dart';
import 'package:backend/src/services/contestacao_service.dart';
import 'package:backend/src/services/denuncia_service.dart';
import 'package:backend/src/services/endereco_service.dart';
import 'package:backend/src/services/eventos_agendamento_listener.dart';
import 'package:backend/src/services/notificacao_service.dart';
import 'package:backend/src/services/pagamento_service.dart';
import 'package:backend/src/services/servico_service.dart';
import 'package:backend/src/services/sessao_service.dart';
import 'package:backend/src/services/usuario_service.dart';
import 'package:backend/src/supabase/supabase_client_factory.dart';
import 'package:backend/src/ws/ws_router.dart';
import 'package:shared/shared.dart';

class Dependencies {
  late final SessaoService sessaoService;
  late final AppHandlers handlers;
  late final WsRouter router;

  late final EventosAgendamentoListener eventosAgendamentoListener;
  late final ConquistaListener conquistaListener;

  Dependencies() {
    _criar();
  }

  void _criar() {
    final supabase = SupabaseClientFactory.criarPublishable();
    final secret = SupabaseClientFactory.criarSecret();

    final usuarioRepository = UsuarioRepository(secret);
    final authRepository = AuthRepository(supabase);
    final notificacaoRepository = NotificacaoRepository(secret);
    final servicoRepository = ServicoRepository(supabase);
    final agendamentoRepository = AgendamentoRepository(secret);

    sessaoService = SessaoService(authRepository, notificacaoRepository);

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

    final chatService = ChatService(sessaoService);
    final denunciaService = DenunciaService(sessaoService);
    final contestacaoService = ContestacaoService(sessaoService);

    final categoriaService = CategoriaService(sessaoService, supabase);

    final servicoService = ServicoService(sessaoService, servicoRepository);

    final notificacaoService = NotificacaoService(
      sessaoService,
      notificacaoRepository,
    );

    final avaliacaoService = AvaliacaoService(sessaoService);

    handlers = AppHandlers(
      auth: AuthHandler(authService),
      usuario: UsuarioHandler(usuarioService),
      endereco: EnderecoHandler(enderecoService),
      admin: AdminHandler(adminService),
      agendamento: AgendamentoHandler(agendamentoService),
      servico: ServicoHandler(servicoService),
      categoria: CategoriaHandler(categoriaService),
      notificacao: NotificacaoHandler(notificacaoService),
      avaliacao: AvaliacaoHandler(avaliacaoService),
      chat: ChatHandler(chatService),
      denuncia: DenunciaHandler(denunciaService),
      contestacao: ContestacaoHandler(contestacaoService),
    );

    router = WsRouter(handlers);

    eventosAgendamentoListener = EventosAgendamentoListener(
      client: secret,
      sessaoService: sessaoService,
      agendamentoRepository: agendamentoRepository,
    );

    conquistaListener = ConquistaListener(
      client: secret,
      sessaoService: sessaoService,
    );

    _configurarSessao();
  }

  void _configurarSessao() {
    sessaoService.onSessaoExpirada = (conexao) {
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.sessaoExpirada,
          mensagem: 'Sessão expirada, faça login novamente',
        ),
      );
    };
  }

  void iniciarListeners() {
    eventosAgendamentoListener.iniciar();
    conquistaListener.iniciar();
  }
}
