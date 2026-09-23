import 'package:ajudai/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/agendamento/agendamento_detalhe_screen.dart';
import 'features/agendamento/agendamentos_recebidos_screen.dart';
import 'features/agendamento/confirmar_pagamento_screen.dart';
import 'features/agendamento/criar_agendamento_screen.dart';
import 'features/agendamento/meus_agendamentos_screen.dart';
import 'features/auth/cadastro_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/avaliacao/avaliar_agendamento_screen.dart';
import 'features/avaliacao/avaliar_usuario_screen.dart';
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

/// Widget raiz do app.
///
/// A tabela de rotas (nome -> tela) fica aqui, não em
/// core/routes/app_routes.dart: aquele arquivo só define os nomes
/// (constantes) e não conhece nenhuma tela, pra não inverter a
/// dependência de core -> features. Este arquivo é o topo da árvore de
/// composição, então é o único lugar com legitimidade de importar todas
/// as features de uma vez.
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
        content: Text('${notificacao.titulo}: ${notificacao.mensagem}'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () {
            _navigatorKey.currentState?.pushNamed(AppRoutes.notificacoes);
          },
        ),
      ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final builders = <String, WidgetBuilder>{
      AppRoutes.login: (_) => const LoginScreen(),
      AppRoutes.cadastro: (_) => const CadastroScreen(),
      AppRoutes.home: (_) => const HomeScreen(),
      AppRoutes.splash: (_) => const SplashScreen(),
      AppRoutes.notificacoes: (_) => const NotificacoesScreen(),
      AppRoutes.meuPerfil: (_) => const MeuPerfilScreen(),
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
      AppRoutes.agendamentoDetalhe: (_) => const AgendamentoDetalheScreen(),
      AppRoutes.avaliarAgendamento: (_) => const AvaliarAgendamentoScreen(),
      AppRoutes.avaliarUsuario: (_) => const AvaliarUsuarioScreen(),
      AppRoutes.solicitarPrestador: (_) => const SolicitarPrestadorScreen(),
      AppRoutes.meusServicosOferecidos: (_) =>
          const MeusServicosOferecidosScreen(),
      AppRoutes.formServicoOferecido: (_) => const FormServicoOferecidoScreen(),
      // TODO: rotas de notificacao/admin — entram aqui conforme as
      // telas forem feitas.
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
