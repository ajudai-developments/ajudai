import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/theme/app_theme.dart';
import 'src/features/auth/presentation/login_page.dart';
import 'src/features/auth/state/auth_controller.dart';
import 'src/features/auth/state/auth_state.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authControllerProvider.notifier).restaurarSessao(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: switch (state) {
        AuthAutenticado() => const _HomePlaceholder(),
        _ => const LoginPage(),
      },
    );
  }
}

class _HomePlaceholder extends ConsumerWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final usuario = state is AuthAutenticado ? state.usuario : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Olá, ${usuario?.nome ?? ''}!'),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref.read(authControllerProvider.notifier).sair(),
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
