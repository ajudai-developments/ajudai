import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../session/sessao.dart';
import '../theme/app_colors.dart';
import 'login_necessario_dialog.dart';

/// Barra de navegação inferior fixa: Agenda / Início / Perfil — e, para
/// quem é prestador, um quarto ícone de Marketplace que leva direto aos
/// agendamentos recebidos (pedidos de clientes).
///
/// NÃO é uma "shell" com IndexedStack — cada aba é uma rota própria de
/// verdade, e trocar de aba faz `pushReplacementNamed` (substitui a
/// rota atual, não empilha). Isso mantém a arquitetura simples (sem
/// gerenciador de estado, sem Navigator aninhado), mas como
/// consequência cada aba perde seu estado/scroll ao trocar pra outra —
/// se isso incomodar no futuro, a evolução natural é migrar pra uma
/// Scaffold "shell" com IndexedStack preservando as abas vivas.
///
/// Usar só nas telas de topo (Home, MeusAgendamentos, MeuPerfil e,
/// agora, AgendamentosRecebidos quando o usuário é prestador) — não em
/// telas de detalhe/formulário.
///
/// Agenda, Perfil e Marketplace exigem sessão ativa — sem ela, o toque
/// nesses não navega: abre LoginNecessarioDialog em vez disso. Início
/// nunca exige login, já que é a tela inicial do app (ver app.dart). O
/// ícone de Marketplace só aparece pra quem já está logado como
/// prestador, então na prática ele nunca é tocado deslogado — o índice
/// fica na lista de "exige login" só por segurança/consistência.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  static const _rotasBase = [
    AppRoutes.meusAgendamentos,
    AppRoutes.home,
    AppRoutes.meuPerfil,
  ];

  /// Índices que exigem sessão ativa (Agenda = 0, Perfil = 2,
  /// Marketplace = 3). Início (1) fica de fora de propósito.
  static const _indicesQueExigemLogin = {0, 2, 3};

  bool get _mostrarMarketplace => Sessao.instance.ehPrestador;

  List<String> get _rotas => [
    ..._rotasBase,
    if (_mostrarMarketplace) AppRoutes.agendamentosRecebidos,
  ];

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
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      selectedItemColor: AppColors.background,
      unselectedItemColor: AppColors.background.withValues(alpha: 0.5),
      backgroundColor: AppColors.primary,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Agenda',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
        if (_mostrarMarketplace)
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Marketplace',
          ),
      ],
    );
  }
}
