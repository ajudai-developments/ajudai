import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cores.surfaceContainerLowest,
      body: Row(
        children: [
          _Sidebar(),
          Expanded(
            child: Column(
              children: [
                _Topbar(),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Painel administrativo',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: cores.surface,
        border: Border(right: BorderSide(color: cores.outlineVariant)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Text(
              'Ajudaí Admin',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_outlined),
            title: Text('Painel'),
            selected: true,
          ),
        ],
      ),
    );
  }
}

class _Topbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: cores.surface,
        border: Border(bottom: BorderSide(color: cores.outlineVariant)),
      ),
      child: Row(
        children: [
          const Text(
            'Painel',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              // TODO: logout (chame o método do seu AuthRepository)
              // e depois: Navigator.of(context)
              //     .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
