import 'package:ajudai/core/session/sessao.dart';
import 'package:ajudai/core/widgets/tela_sem_acesso.dart';
import 'package:ajudai/features/admin/admin_dashboard_screen.dart';
import 'package:ajudai/features/agendamento/agendamento_detalhado_screen.dart';
import 'package:ajudai/features/contestacao/contestacao_detalhe_screen.dart';
import 'package:ajudai/features/contestacao/contestar_agendamento_screen.dart';
import 'package:ajudai/features/contestacao/minhas_contestacoes_screen.dart';
import 'package:ajudai/features/denuncia/denuncia_detalhe_screen.dart';
import 'package:ajudai/features/denuncia/denunciar_usuario_screen.dart';
import 'package:ajudai/features/denuncia/minhas_denuncias_screen.dart';
import 'package:ajudai/features/notificacao/widgets/notificacao_snack_bar_content.dart';
import 'package:ajudai/features/prestador/minha_solicitacao_prestador_screen.dart';
import 'package:ajudai/features/prestador/servico_oferecido_detalhe_screen.dart';
import 'package:ajudai/features/splash/splash_screen.dart';
import 'package:ajudai/features/usuario/meu_perfil_completo_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/agendamento/agendamentos_recebidos_screen.dart';
import 'features/agendamento/confirmar_pagamento_screen.dart';
import 'features/agendamento/criar_agendamento_screen.dart';
import 'features/agendamento/meus_agendamentos_screen.dart';
import 'features/auth/cadastro_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/avaliacao/avaliar_agendamento_screen.dart';
import 'features/conversas/conversa_screen.dart';
import 'features/conversas/conversas_repository.dart';
import 'features/conversas/conversas_screen.dart';
import 'features/endereco/form_endereco_screen.dart';
import 'features/endereco/meus_enderecos_screen.dart';
import 'features/perfil/perfil_publico_screen.dart';
import 'features/prestador/form_servico_oferecido_screen.dart';
import 'features/prestador/meus_servicos_oferecidos_screen.dart';
import 'features/prestador/solicitar_prestador_screen.dart';
import 'features/home/home_screen.dart';
import 'features/notificacao/notificacoes_screen.dart';
import 'features/notificacao/notificacao_repository.dart';
import 'features/servico/categorias_screen.dart';
import 'features/servico/servico_detalhe_screen.dart';
import 'features/servico/servicos_lista_screen.dart';
import 'features/usuario/editar_perfil_screen.dart';
import 'features/usuario/meu_perfil_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppRoot();
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _notificacaoRepository = NotificacaoRepository();
  final _conversasRepository = ConversasRepository();

  Stream<NotificacaoDto>? _notificacoes;

  @override
  void initState() {
    super.initState();
    _notificacoes = _notificacaoRepository.escutarNotificacoesPush();
    _notificacoes?.listen(_mostrarNotificacao);
  }

  void _mostrarNotificacao(NotificacaoDto notificacao) {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        content: NotificacaoSnackBarContent(notificacao: notificacao),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () => _abrirNotificacao(notificacao),
        ),
      ),
    );
  }

  Future<void> _abrirNotificacao(NotificacaoDto notificacao) async {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    final dados = notificacao.dados;

    switch (notificacao.categoria) {
      case CategoriaNotificacao.agendamento:
        final agendamentoId = dados?['agendamento_id'] as String?;
        if (agendamentoId == null) break;
        navigator.pushNamed(
          AppRoutes.agendamentoDetalhe,
          arguments: agendamentoId,
        );
        return;

      case CategoriaNotificacao.conversa:
        final conversaId = dados?['conversa_id'] as String?;
        if (conversaId == null) break;
        try {
          final conversa = await _conversasRepository.buscarConversa(
            conversaId,
          );
          navigator.pushNamed(AppRoutes.conversa, arguments: conversa);
          return;
        } catch (_) {
          break;
        }

      case CategoriaNotificacao.geral:
        break;
    }

    navigator.pushNamed(AppRoutes.notificacoes);
  }

  static const _rotasSomenteMobile = {
    AppRoutes.criarAgendamento,
    AppRoutes.confirmarPagamento,
  };

  static const _rotasAdmin = <String>{AppRoutes.adminDashboard};

  /// Rotas que um admin PODE acessar. Fora dessa lista, qualquer tentativa
  /// de navegação enquanto logado como admin é redirecionada pro
  /// dashboard — o admin não deve "passear" pelo app normal (agendar
  /// serviço, ver categorias etc.), só usar a área administrativa.
  ///
  /// login/cadastro/splash ficam de fora de propósito: um admin nunca
  /// deveria precisar visitar essas telas estando logado, mas não custa
  /// não travar caso aconteça algo fora do fluxo esperado (deep link, etc).
  static const _rotasPermitidasParaAdmin = <String>{
    AppRoutes.adminDashboard,
    AppRoutes.login,
    AppRoutes.cadastro,
    AppRoutes.splash,
  };

  Route<dynamic> _rotaBloqueada(RouteSettings settings, String mensagem) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => TelaSemAcesso(mensagem: mensagem),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final nome = settings.name;
    final perm = Sessao.instance.permissoes;
    if (nome == AppRoutes.conversa) {
      final conversa = settings.arguments as ConversaResumo;
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => ConversaScreen(conversa: conversa),
      );
    }

    if (_rotasSomenteMobile.contains(nome) && kIsWeb) {
      return _rotaBloqueada(settings, 'Disponível apenas no app.');
    }
    if (_rotasAdmin.contains(nome) && perm.papel != UserRole.admin) {
      return _rotaBloqueada(settings, 'Acesso restrito.');
    }

    if (perm.papel == UserRole.admin &&
        !_rotasPermitidasParaAdmin.contains(nome)) {
      return MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.adminDashboard),
        builder: (_) => const AdminDashboardScreen(),
      );
    }

    final builders = <String, WidgetBuilder>{
      AppRoutes.login: (_) => const LoginScreen(),
      AppRoutes.cadastro: (_) => const CadastroScreen(),
      AppRoutes.home: (_) => const HomeScreen(),
      AppRoutes.splash: (_) => const SplashScreen(),
      AppRoutes.notificacoes: (_) => const NotificacoesScreen(),
      AppRoutes.conversas: (_) => const ConversasScreen(),
      AppRoutes.meuPerfil: (_) => const MeuPerfilScreen(),
      AppRoutes.meuPerfilCompleto: (_) => const MeuPerfilCompletoScreen(),
      AppRoutes.editarPerfil: (_) => const EditarPerfilScreen(),
      AppRoutes.meusEnderecos: (_) => const MeusEnderecosScreen(),
      AppRoutes.formEndereco: (_) => const FormEnderecoScreen(),
      AppRoutes.perfilPublico: (_) => const PerfilPublicoScreen(),
      AppRoutes.categorias: (_) => const CategoriasScreen(),
      AppRoutes.servicosLista: (_) => const ServicosListaScreen(),
      AppRoutes.servicoDetalhe: (_) => const ServicoDetalheScreen(),
      AppRoutes.criarAgendamento: (_) => const CriarAgendamentoScreen(),
      AppRoutes.confirmarPagamento: (_) => const ConfirmarPagamentoScreen(),
      AppRoutes.meusAgendamentos: (_) => const MeusAgendamentosScreen(),
      AppRoutes.agendamentosRecebidos: (_) =>
          const AgendamentosRecebidosScreen(),
      AppRoutes.agendamentoDetalhe: (_) => const AgendamentoDetalhadoScreen(),
      AppRoutes.avaliarAgendamento: (_) => const AvaliarAgendamentoScreen(),
      AppRoutes.solicitarPrestador: (_) => const SolicitarPrestadorScreen(),
      AppRoutes.minhaSolicitacaoPrestador: (_) =>
          const MinhaSolicitacaoPrestadorScreen(),
      AppRoutes.meusServicosOferecidos: (_) =>
          const MeusServicosOferecidosScreen(),
      AppRoutes.formServicoOferecido: (_) => const FormServicoOferecidoScreen(),
      AppRoutes.denunciarUsuario: (_) => const DenunciarUsuarioScreen(),
      AppRoutes.contestarAgendamento: (_) => const ContestarAgendamentoScreen(),
      AppRoutes.servicoOferecidoDetalhe: (_) =>
          const ServicoOferecidoDetalheScreen(),

      AppRoutes.minhasContestacoes: (_) => const MinhasContestacoesScreen(),
      AppRoutes.minhasDenuncias: (_) => const MinhasDenunciasScreen(),
      AppRoutes.contestacaoDetalhe: (_) => const ContestacaoDetalheScreen(),
      AppRoutes.denunciaDetalhe: (_) => const DenunciaDetalheScreen(),
      AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
    };

    final builder = builders[settings.name];

    if (builder == null) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => _TelaNaoImplementada(nomeRota: settings.name),
      );
    }

    return MaterialPageRoute(settings: settings, builder: builder);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ajudaí',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      navigatorKey: _navigatorKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

class _TelaNaoImplementada extends StatelessWidget {
  final String? nomeRota;

  const _TelaNaoImplementada({required this.nomeRota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Em construção')),
      body: Center(
        child: Text('Tela para "${nomeRota ?? '?'}" ainda não implementada.'),
      ),
    );
  }
}
