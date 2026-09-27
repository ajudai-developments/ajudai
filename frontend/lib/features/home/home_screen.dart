import 'package:ajudai/core/ws/ws_message_stream.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/session/sessao.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/categoria_card.dart';
import '../servico/servico_repository.dart';
import 'home_repository.dart';
import 'widgets/agendamento_proximo_card.dart';

/// Quantidade de categorias mostradas na grade da Home antes de precisar
/// tocar em "Ver mais" (que leva pra categorias_screen, com a lista
/// completa). Puramente de exibição, não é um limite de paginação real
/// vindo do backend — listarCategorias já devolve tudo de uma vez.
const _maxCategoriasNaHome = 6;

/// Tela inicial do app (ver protótipo compartilhado).
///
/// Estrutura da tela, de cima pra baixo:
/// 1. Cabeçalho — fundo vermelho arredondado embaixo (mesmo padrão visual
///    de CabecalhoComAbas), com saudação e notificações.
/// 2. Agendamentos próximos — só aparece se houver usuário logado.
///    Mostra o agendamento mais próximo como cliente e, se o usuário
///    também for prestador, o mais próximo como prestador. Seção fica
///    oculta se não houver nada a mostrar (sem sessão, sem agendamento
///    próximo, etc).
/// 3. Categorias de serviço — grade com as primeiras
///    [_maxCategoriasNaHome], "Ver mais" abre categorias_screen com a
///    lista completa.
/// 4. Central de suporte — atalhos pra Minhas contestações e Minhas
///    denúncias. Só aparece logado (são telas de "minhas ...").
/// 5. "Serviços recentes" — NÃO implementar ainda (sem endpoint no
///    backend). Seção fica oculta até existir.
///
/// Categorias e agendamentos são buscados com estado próprio (não usa
/// AsyncListView) porque esta tela tem várias seções na mesma lista
/// rolável — encaixar o ListView interno do AsyncListView aqui dentro
/// criaria conflito de scroll. AsyncListView é pra telas onde a lista É
/// o body inteiro.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _servicoRepository = ServicoRepository();
  final _homeRepository = HomeRepository();

  bool _carregandoCategorias = true;
  String? _erroCategorias;
  List<Categoria> _categorias = [];

  bool _carregandoAgendamentos = true;
  String? _erroAgendamentos;
  AgendamentoDetalhadoCliente? _agendamentoCliente;
  AgendamentoDetalhadoPrestador? _agendamentoPrestador;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
    _carregarAgendamentos();
  }

  Future<void> _atualizarTudo() async {
    await Future.wait([_carregarCategorias(), _carregarAgendamentos()]);
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

  Future<void> _carregarAgendamentos() async {
    if (!Sessao.instance.estaLogado) {
      setState(() {
        _carregandoAgendamentos = false;
        _agendamentoCliente = null;
        _agendamentoPrestador = null;
        _erroAgendamentos = null;
      });
      return;
    }

    setState(() {
      _carregandoAgendamentos = true;
      _erroAgendamentos = null;
    });

    try {
      final ehPrestador = Sessao.instance.ehPrestador;

      final resultados = await Future.wait([
        _homeRepository.buscarAgendamentoProximoCliente(),
        if (ehPrestador) _homeRepository.buscarAgendamentoProximoPrestador(),
      ]);

      setState(() {
        _agendamentoCliente = resultados[0] as AgendamentoDetalhadoCliente?;
        _agendamentoPrestador = ehPrestador
            ? resultados[1] as AgendamentoDetalhadoPrestador?
            : null;
      });
    } on WsErroException catch (e) {
      setState(() {
        _erroAgendamentos = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      setState(
        () =>
            _erroAgendamentos = 'Não foi possível carregar seus agendamentos.',
      );
    } finally {
      if (mounted) setState(() => _carregandoAgendamentos = false);
    }
  }

  void _abrirCategoria(Categoria categoria) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.servicosLista, arguments: categoria);
  }

  @override
  Widget build(BuildContext context) {
    final nome = Sessao.instance.usuario?.nome.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _HomeHeader(nome: nome),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _atualizarTudo,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  _buildAgendamentosSection(),

                  _buildSectionHeader(
                    titulo: 'Serviços disponíveis',
                    aoTocarAcao: _categorias.length > _maxCategoriasNaHome
                        ? () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.categorias)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildCategorias(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildSectionHeader({
    required String titulo,
    VoidCallback? aoTocarAcao,
    String rotuloAcao = 'Ver mais',
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: AppTextStyles.titulo),
        if (aoTocarAcao != null)
          TextButton(onPressed: aoTocarAcao, child: Text(rotuloAcao)),
      ],
    );
  }

  Widget _buildAgendamentosSection() {
    if (!Sessao.instance.estaLogado) return const SizedBox.shrink();

    final semConteudo =
        !_carregandoAgendamentos &&
        _erroAgendamentos == null &&
        _agendamentoCliente == null &&
        _agendamentoPrestador == null;

    if (semConteudo) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            titulo: 'Seus agendamentos',
            aoTocarAcao: () =>
                Navigator.of(context).pushNamed(AppRoutes.meusAgendamentos),
            rotuloAcao: 'Ver todos',
          ),
          const SizedBox(height: 12),
          _buildAgendamentos(),
        ],
      ),
    );
  }

  Widget _buildAgendamentos() {
    if (_carregandoAgendamentos) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_erroAgendamentos != null) {
      return Text(_erroAgendamentos!, style: AppTextStyles.corpo);
    }

    final cards = <Widget>[
      if (_agendamentoCliente != null)
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.agendamentoDetalhe,
            arguments: _agendamentoCliente!.agendamento.id,
          ),
          child: AgendamentoProximoCard(
            nome: _agendamentoCliente!.prestadorNome,
            avatarUrl: _agendamentoCliente!.prestadorAvatarUrl,
            verificado: _agendamentoCliente!.prestadorVerificado,
            agendamento: _agendamentoCliente!.agendamento,
            subtitulo: 'Você contratou',
          ),
        ),
      if (_agendamentoPrestador != null)
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.agendamentoDetalhe,
            arguments: _agendamentoPrestador!.agendamento.id,
          ),
          child: AgendamentoProximoCard(
            nome: _agendamentoPrestador!.clienteNome,
            avatarUrl: _agendamentoPrestador!.clienteAvatarUrl,
            verificado: _agendamentoPrestador!.clienteVerificado,
            agendamento: _agendamentoPrestador!.agendamento,
            subtitulo: 'Cliente agendou com você',
          ),
        ),
    ];

    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          cards[i],
          if (i != cards.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildCategorias() {
    if (_carregandoCategorias) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
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
      childAspectRatio: 0.95,
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

/// Cabeçalho da Home — mesmo padrão visual de [CabecalhoComAbas] (fundo
/// vermelho, cantos arredondados embaixo), mas sem abas: aqui é só
/// saudação + botão de notificações.
class _HomeHeader extends StatelessWidget {
  final String? nome;

  const _HomeHeader({required this.nome});

  @override
  Widget build(BuildContext context) {
    final saudacao = nome != null ? 'Olá, $nome' : 'Bem-vindo';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    saudacao,
                    style: AppTextStyles.display.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Do que você precisa hoje?',
                    style: AppTextStyles.corpo.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.notificacoes),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
