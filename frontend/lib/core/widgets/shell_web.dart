import 'package:ajudai/core/widgets/ajudai_logo.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../session/sessao.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Casca padrão das telas no layout web/desktop: sidebar à esquerda,
/// topbar em cima e o [child] ocupando o resto.
///
/// O [child] cuida do próprio scroll (ex: SingleChildScrollView).
/// No mobile NÃO use isto: cada tela continua com seu Scaffold.
class ShellWeb extends StatelessWidget {
  final String titulo;

  /// Rota da tela atual, para destacar o item ativo na sidebar.
  final String rotaAtual;
  final Widget child;
  final List<Widget> acoes;

  const ShellWeb({
    super.key,
    required this.titulo,
    required this.rotaAtual,
    required this.child,
    this.acoes = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _Sidebar(rotaAtual: rotaAtual),
          Expanded(
            child: Column(
              children: [
                _Topbar(titulo: titulo, acoes: acoes),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemMenu {
  final String rota;
  final String titulo;
  final IconData icone;
  const _ItemMenu(this.rota, this.titulo, this.icone);
}

List<_ItemMenu> _itensDoMenu() {
  final s = Sessao.instance;
  return [
    const _ItemMenu(AppRoutes.home, 'Início', Icons.home_outlined),
    const _ItemMenu(
      AppRoutes.categorias,
      'Categorias',
      Icons.grid_view_outlined,
    ),
    if (s.estaLogado) ...[
      const _ItemMenu(
        AppRoutes.meusAgendamentos,
        'Meus agendamentos',
        Icons.event_outlined,
      ),
      if (s.ehPrestador) ...const [
        _ItemMenu(
          AppRoutes.agendamentosRecebidos,
          'Agendamentos recebidos',
          Icons.inbox_outlined,
        ),
        _ItemMenu(
          AppRoutes.meusServicosOferecidos,
          'Meus serviços',
          Icons.handyman_outlined,
        ),
      ],
      const _ItemMenu(
        AppRoutes.conversas,
        'Conversas',
        Icons.chat_bubble_outline,
      ),
      const _ItemMenu(
        AppRoutes.notificacoes,
        'Notificações',
        Icons.notifications_none_rounded,
      ),
      const _ItemMenu(AppRoutes.meuPerfil, 'Perfil', Icons.person_outline),
    ],
  ];
}

class _Sidebar extends StatelessWidget {
  final String rotaAtual;
  const _Sidebar({required this.rotaAtual});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Sessao.instance,
      builder: (context, _) {
        final itens = _itensDoMenu();

        return Container(
          width: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
                  child: AjudaiLogo(),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final item in itens)
                      _ItemSidebar(item: item, ativo: item.rota == rotaAtual),
                  ],
                ),
              ),
              const Divider(height: 1),
              const _RodapeSidebar(),
            ],
          ),
        );
      },
    );
  }
}

class _ItemSidebar extends StatelessWidget {
  final _ItemMenu item;
  final bool ativo;
  const _ItemSidebar({required this.item, required this.ativo});

  @override
  Widget build(BuildContext context) {
    final cor = ativo ? AppColors.primary : Colors.grey.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: ativo
            ? AppColors.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: ativo
              ? null
              : () => Navigator.of(context).pushReplacementNamed(item.rota),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(item.icone, size: 20, color: cor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.titulo,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.corpo.copyWith(
                      color: cor,
                      fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RodapeSidebar extends StatelessWidget {
  const _RodapeSidebar();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Sessao.instance,
      builder: (context, _) {
        final sessao = Sessao.instance;

        if (!sessao.estaLogado) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.login),
                child: const Text('Entrar'),
              ),
            ),
          );
        }

        final nome = sessao.usuario?.nome ?? '';

        return InkWell(
          onTap: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.meuPerfil),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.corpo.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Topbar extends StatelessWidget {
  final String titulo;
  final List<Widget> acoes;
  const _Topbar({required this.titulo, required this.acoes});

  @override
  Widget build(BuildContext context) {
    final podeVoltar = Navigator.of(context).canPop();

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          if (podeVoltar) ...[
            IconButton(
              tooltip: 'Voltar',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 8),
          ],
          Text(titulo, style: AppTextStyles.titulo),
          const Spacer(),
          ...acoes,
        ],
      ),
    );
  }
}
