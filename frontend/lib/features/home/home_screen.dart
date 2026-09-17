import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/categoria_card.dart';
import '../../core/ws/ws_message_stream.dart';
import '../servico/servico_repository.dart';
import 'widgets/mapa_placeholder.dart';

/// Quantidade de categorias mostradas na grade da Home antes de precisar
/// tocar em "Ver mais" (que leva pra categorias_screen, com a lista
/// completa). Puramente de exibição, não é um limite de paginação real
/// vindo do backend — listarCategorias já devolve tudo de uma vez.
const _maxCategoriasNaHome = 6;

/// Tela inicial do app (ver protótipo compartilhado).
///
/// Estrutura da tela, de cima pra baixo:
/// 1. Busca — NÃO implementar ainda (sem filtro no backend).
/// 2. Mapa de serviços próximos — placeholder por enquanto (ver
///    mapa_placeholder.dart), sem geolocalização real.
/// 3. Categorias de serviço — grade com as primeiras
///    [_maxCategoriasNaHome], "Ver mais" abre categorias_screen com a
///    lista completa.
/// 4. "Serviços recentes" — NÃO implementar ainda (sem endpoint no
///    backend). Seção fica oculta até existir.
///
/// Categorias são buscadas com estado próprio (não usa AsyncListView)
/// porque esta tela tem várias seções na mesma lista rolável — encaixar
/// o ListView interno do AsyncListView aqui dentro criaria conflito de
/// scroll. AsyncListView é pra telas onde a lista É o body inteiro.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _servicoRepository = ServicoRepository();

  bool _carregandoCategorias = true;
  String? _erroCategorias;
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    setState(() {
      _carregandoCategorias = true;
      _erroCategorias = null;
    });

    try {
      final categorias = await _servicoRepository.listarCategorias();
      setState(() => _categorias = categorias);
    } on WsErroException catch (e) {
      setState(() {
        _erroCategorias = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      setState(
        () => _erroCategorias = 'Não foi possível carregar as categorias.',
      );
    } finally {
      if (mounted) setState(() => _carregandoCategorias = false);
    }
  }

  void _abrirCategoria(Categoria categoria) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.servicosLista, arguments: categoria);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _carregarCategorias,
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Serviços disponíveis', style: AppTextStyles.titulo),
                  if (_categorias.length > _maxCategoriasNaHome)
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.categorias),
                      child: const Text('Ver mais'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildCategorias(),

              // TODO: "Serviços recentes" — sem endpoint no backend ainda.
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildCategorias() {
    if (_carregandoCategorias) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_erroCategorias != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(_erroCategorias!, style: AppTextStyles.corpo),
      );
    }

    if (_categorias.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Nenhuma categoria disponível no momento.',
          style: AppTextStyles.corpo,
        ),
      );
    }

    final exibidas = _categorias.take(_maxCategoriasNaHome).toList();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        for (final categoria in exibidas)
          CategoriaCard(
            categoria: categoria,
            onTap: () => _abrirCategoria(categoria),
          ),
      ],
    );
  }
}
