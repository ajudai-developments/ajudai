import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_nav.dart';
import 'widgets/mapa_placeholder.dart';

/// Tela inicial do app (ver protótipo compartilhado).
///
/// Estrutura da tela, de cima pra baixo:
/// 1. Busca — NÃO implementar ainda (sem filtro no backend).
/// 2. Mapa de serviços próximos — placeholder por enquanto (ver
///    mapa_placeholder.dart), sem geolocalização real.
/// 3. Categorias de serviço — ÚNICA seção com dado real disponível hoje
///    (HomeRepository.obterCategorias). Ainda não implementada aqui.
/// 4. "Serviços recentes" — NÃO implementar ainda (sem endpoint no
///    backend). Seção deve ficar oculta até existir.
///
/// Navegação inferior (bottom nav): Agenda / Home / Perfil — a decidir
/// se fica dentro desta mesma Screen (com IndexedStack) ou num widget
/// de shell separado que envolve várias tabs. Por enquanto só a Home
/// existe, então deixei o Scaffold preparado mas sem bottom nav ainda.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Início', style: AppTextStyles.titulo),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.notificacoes),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // TODO: busca — sem filtro implementado no backend ainda.
            const MapaPlaceholder(),
            const SizedBox(height: 24),

            Text('Serviços disponíveis', style: AppTextStyles.titulo),
            const SizedBox(height: 8),
            // TODO: grade de CategoriaCard usando ServicoRepository().listarCategorias()

            // TODO: "Serviços recentes" — sem endpoint no backend ainda.
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
