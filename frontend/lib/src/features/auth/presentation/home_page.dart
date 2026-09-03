import 'package:ajudai/src/features/perfil/presentation/widgets/categorias_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/auth_controller.dart';
import '../../auth/state/auth_state.dart';
import '../../perfil/presentation/perfil_view.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _abaAtual = 0;

  static const _paginas = [CategoriasView(), PerfilView()];
  static const _titulos = ['Início', 'Meu perfil'];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final usuario = authState is AuthAutenticado ? authState.usuario : null;

    final titulo = _abaAtual == 0
        ? 'Olá, ${usuario?.nome.split(' ').first ?? ''}!'
        : _titulos[_abaAtual];

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: IndexedStack(index: _abaAtual, children: _paginas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaAtual,
        onDestinationSelected: (index) => setState(() => _abaAtual = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}