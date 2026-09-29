import 'package:ajudai/core/widgets/ajudai_logo.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../session/sessao.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Casca das telas do ADMIN (somente web): sidebar com o menu
/// administrativo, topbar e o [child] ocupando o resto.
///
/// Mesma estrutura do [ShellWeb], mas com menu próprio — o admin nunca
/// vê os itens do usuário comum (agendamentos, conversas, etc).
class ShellAdmin extends StatelessWidget {
  final String titulo;

  /// Rota da tela atual, para destacar o item ativo na sidebar.
  final String rotaAtual;
  final Widget child;
  final List<Widget> acoes;

  const ShellAdmin({
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
          _SidebarAdmin(rotaAtual: rotaAtual),
          Expanded(
            child: Column(
              children: [
                _TopbarAdmin(titulo: titulo, acoes: acoes),
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

const _itensAdmin = <_ItemMenu>[
  _ItemMenu(AppRoutes.adminDashboard, 'Painel', Icons.dashboard_outlined),
  _ItemMenu(
    AppRoutes.verificacoes,
    'Verificações',
    Icons.verified_user_outlined,
  ),
  _ItemMenu(AppRoutes.adminContestacoes, 'Contestações', Icons.gavel_outlined),
  _ItemMenu(AppRoutes.adminDenuncias, 'Denúncias', Icons.flag_outlined),
];

class _SidebarAdmin extends StatelessWidget {
  final String rotaAtual;
  const _SidebarAdmin({required this.rotaAtual});

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.adminDashboard),
              child: const AjudaiLogo(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'ÁREA ADMINISTRATIVA',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final item in _itensAdmin)
                  _ItemSidebar(item: item, ativo: item.rota == rotaAtual),
              ],
            ),
          ),
          const Divider(height: 1),
          const _RodapeAdmin(),
        ],
      ),
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

class _RodapeAdmin extends StatelessWidget {
  const _RodapeAdmin();

  Future<void> _sair(BuildContext context) async {
    // TODO: chame aqui o logout da sua Sessao (limpar token/usuário).
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Sessao.instance,
      builder: (context, _) {
        final nome = Sessao.instance.usuario?.nome ?? 'Admin';

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
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
              IconButton(
                tooltip: 'Sair',
                icon: const Icon(Icons.logout_rounded, size: 20),
                color: AppColors.textoSecundario,
                onPressed: () => _sair(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopbarAdmin extends StatelessWidget {
  final String titulo;
  final List<Widget> acoes;
  const _TopbarAdmin({required this.titulo, required this.acoes});

  @override
  Widget build(BuildContext context) {
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
          Text(titulo, style: AppTextStyles.titulo),
          const Spacer(),
          ...acoes,
        ],
      ),
    );
  }
}
