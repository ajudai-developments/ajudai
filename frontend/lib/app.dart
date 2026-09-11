import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/agendamento/agendamento_detalhe_screen.dart';
import 'features/agendamento/agendamentos_recebidos_screen.dart';
import 'features/agendamento/confirmar_pagamento_screen.dart';
import 'features/agendamento/criar_agendamento_screen.dart';
import 'features/agendamento/meus_agendamentos_screen.dart';
import 'features/auth/cadastro_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/endereco/form_endereco_screen.dart';
import 'features/endereco/meus_enderecos_screen.dart';
import 'features/home/home_screen.dart';
import 'features/servico/categorias_screen.dart';
import 'features/servico/servico_detalhe_screen.dart';
import 'features/servico/servicos_lista_screen.dart';

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
    return MaterialApp(
      title: 'App', // TODO: nome definitivo do app
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final builders = <String, WidgetBuilder>{
      AppRoutes.login: (_) => const LoginScreen(),
      AppRoutes.cadastro: (_) => const CadastroScreen(),
      AppRoutes.home: (_) => const HomeScreen(),
      AppRoutes.meusEnderecos: (_) => const MeusEnderecosScreen(),
      AppRoutes.formEndereco: (_) => const FormEnderecoScreen(),
      AppRoutes.categorias: (_) => const CategoriasScreen(),
      AppRoutes.servicosLista: (_) => const ServicosListaScreen(),
      AppRoutes.servicoDetalhe: (_) => const ServicoDetalheScreen(),
      AppRoutes.criarAgendamento: (_) => const CriarAgendamentoScreen(),
      AppRoutes.confirmarPagamento: (_) => const ConfirmarPagamentoScreen(),
      AppRoutes.meusAgendamentos: (_) => const MeusAgendamentosScreen(),
      AppRoutes.agendamentosRecebidos: (_) => const AgendamentosRecebidosScreen(),
      AppRoutes.agendamentoDetalhe: (_) => const AgendamentoDetalheScreen(),
      // TODO: demais rotas (perfil, prestador, avaliacao, notificacao,
      // admin) — entram aqui conforme as telas forem feitas.
    };

    final builder = builders[settings.name];

    if (builder == null) {
      // Rota ainda não implementada: mostra um placeholder em vez de
      // travar a navegação com erro — útil enquanto o app está em
      // construção. Remover este fallback quando todas as rotas
      // existirem de verdade.
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => _TelaNaoImplementada(nomeRota: settings.name),
      );
    }

    return MaterialPageRoute(settings: settings, builder: builder);
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