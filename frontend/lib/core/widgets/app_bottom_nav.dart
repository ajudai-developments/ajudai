import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../session/sessao.dart';
import '../theme/app_colors.dart';
import 'login_necessario_dialog.dart';

/// Barra de navegação inferior fixa: Agenda / Início / Perfil.
///
/// NÃO é uma "shell" com IndexedStack — cada aba é uma rota própria de
/// verdade, e trocar de aba faz `pushReplacementNamed` (substitui a
/// rota atual, não empilha). Isso mantém a arquitetura simples (sem
/// gerenciador de estado, sem Navigator aninhado), mas como
/// consequência cada aba perde seu estado/scroll ao trocar pra outra —
/// se isso incomodar no futuro, a evolução natural é migrar pra uma
/// Scaffold "shell" com IndexedStack preservando as 3 abas vivas.
///
/// Usar só nas telas de topo (Home, MeusAgendamentos, MeuPerfil) — não
/// em telas de detalhe/formulário.
///
/// Agenda e Perfil exigem sessão ativa — sem ela, o toque nesses dois
/// não navega: abre LoginNecessarioDialog em vez disso. Início nunca
/// exige login, já que agora é a tela inicial do app (ver app.dart).
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  static const _rotas = [
    AppRoutes.meusAgendamentos,
    AppRoutes.home,
    AppRoutes.meuPerfil,
  ];

  /// Índices que exigem sessão ativa (Agenda = 0, Perfil = 2). Início (1)
  /// fica de fora de propósito.
  static const _indicesQueExigemLogin = {0, 2};

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (_indicesQueExigemLogin.contains(index) && !Sessao.instance.estaLogado) {
      LoginNecessarioDialog.mostrar(context);
      return;
    }

    Navigator.of(context).pushReplacementNamed(_rotas[index]);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      selectedItemColor: AppColors.background,
      unselectedItemColor: AppColors.background.withValues(alpha: 0.5),
      backgroundColor: AppColors.primary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Agenda',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
