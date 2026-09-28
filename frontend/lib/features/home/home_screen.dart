import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/session/permissoes.dart';
import 'package:ajudai/core/widgets/shell_web.dart';
import 'package:ajudai/core/ws/ws_message_stream.dart';
import 'package:ajudai/features/usuario/usuario_repository.dart';
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
import 'widgets/prestador_recente_card.dart';
import 'widgets/servico_recente_card.dart';

/// Categorias mostradas na grade da Home antes de "Ver mais".
/// Puramente de exibição (listarCategorias já devolve tudo).
const _maxCategoriasMobile = 6;
const _maxCategoriasWeb = 15;

/// Tela inicial do app.
///
/// Dois layouts, mesma lógica de dados:
/// - Mobile: cabeçalho vermelho + lista rolável + bottom nav.
/// - Web/desktop: [ShellWeb] (sidebar + topbar), banner de boas-vindas
///   e seções em painéis. No desktop largo, duas colunas: principal
///   (categorias, serviços recentes) e lateral (agendamentos próximos,
///   prestadores recentes). Em telas médias, coluna única.
///
/// As seções de recentes são secundárias: se a chamada falhar, elas
/// simplesmente não aparecem.
///
/// Não usa AsyncListView porque há várias seções na mesma área rolável.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _servicoRepository = ServicoRepository();
  final _usuarioRepository = UsuarioRepository();
  final _homeRepository = HomeRepository();

  bool _carregandoCategorias = true;
  String? _erroCategorias;
  List<Categoria> _categorias = [];

  bool _carregandoAgendamentos = true;
  String? _erroAgendamentos;
  AgendamentoDetalhadoCliente? _agendamentoCliente;
  AgendamentoDetalhadoPrestador? _agendamentoPrestador;

  List<ServicoRecente> _servicosRecentes = [];
  List<PrestadorRecente> _prestadoresRecentes = [];

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
    _carregarAgendamentos();
    _carregarRecentes();
  }

  // ---------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------

  Future<void> _atualizarTudo() async {
    await Future.wait([
      _carregarCategorias(),
      _carregarAgendamentos(),
      _carregarRecentes(),
    ]);
  }

  Future<void> _carregarCategorias() async {
    setState(() {
      _carregandoCategorias = true;
      _erroCategorias = null;
    });

    try {
      final categorias = await _servicoRepository.listarCategorias();
      if (!mounted) return;
      setState(() => _categorias = categorias);
    } on WsErroException catch (e) {
      if (!mounted) return;
      setState(() {
        _erroCategorias = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      if (!mounted) return;
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

      if (!mounted) return;
      setState(() {
        _agendamentoCliente = resultados[0] as AgendamentoDetalhadoCliente?;
        _agendamentoPrestador = ehPrestador
            ? resultados[1] as AgendamentoDetalhadoPrestador?
            : null;
      });
    } on WsErroException catch (e) {
      if (!mounted) return;
      setState(() {
        _erroAgendamentos = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      if (!mounted) return;
      setState(
        () =>
            _erroAgendamentos = 'Não foi possível carregar seus agendamentos.',
      );
    } finally {
      if (mounted) setState(() => _carregandoAgendamentos = false);
    }
  }

  /// Serviços e prestadores recentes. Falhas são silenciosas: a seção
  /// só não aparece.
  Future<void> _carregarRecentes() async {
    if (!Sessao.instance.estaLogado) {
      setState(() {
        _servicosRecentes = [];
        _prestadoresRecentes = [];
      });
      return;
    }

    var servicos = <ServicoRecente>[];
    var prestadores = <PrestadorRecente>[];

    try {
      servicos = await _servicoRepository.listarServicosRecentes();
    } on WsErroException {
      // seção opcional
    } on WsTimeoutException {
      // seção opcional
    }

    try {
      prestadores = await _usuarioRepository.listarPrestadoresRecentes();
    } on WsErroException {
      // seção opcional
    } on WsTimeoutException {
      // seção opcional
    }

    if (!mounted) return;
    setState(() {
      _servicosRecentes = servicos;
      _prestadoresRecentes = prestadores;
    });
  }

  // ---------------------------------------------------------------
  // Navegação
  // ---------------------------------------------------------------

  void _abrirCategoria(Categoria categoria) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.servicosLista, arguments: categoria);
  }

  void _abrirServicoRecente(ServicoRecente servico) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.servicosLista, arguments: servico);
  }

  Future<void> _abrirPrestadorRecente(PrestadorRecente prestador) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.servicoDetalhe,
      arguments: prestador.servicoOferecidoId,
    );
    await _carregarAgendamentos();
  }

  void _abrirAgendamento(String id) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.agendamentoDetalhe, arguments: id);
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return context.ehMobile ? _buildMobile() : _buildWeb();
  }

  Widget _buildMobile() {
    final nome = Sessao.instance.usuario?.nome.split(' ').first;

    final secoes = _empilhar([
      _secaoAgendamentos(web: false),
      _secaoCategorias(web: false),
      _secaoServicosRecentes(web: false),
      _secaoPrestadoresRecentes(web: false),
    ], 28);

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
                children: secoes,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildWeb() {
    final nome = Sessao.instance.usuario?.nome.split(' ').first;
    final logado = Sessao.instance.estaLogado;
    final desktop = context.ehDesktop;

    final principal = _empilhar([
      _secaoCategorias(web: true),
      _secaoServicosRecentes(web: true),
    ], 24);

    final lateral = _empilhar([
      _secaoAgendamentos(web: true),
      _secaoPrestadoresRecentes(web: true),
    ], 24);

    final Widget corpo;
    if (desktop && lateral.isNotEmpty) {
      corpo = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: principal)),
          const SizedBox(width: 24),
          SizedBox(width: 380, child: Column(children: lateral)),
        ],
      );
    } else {
      // Coluna única, na mesma ordem do mobile.
      corpo = Column(
        children: _empilhar([
          _secaoAgendamentos(web: true),
          _secaoCategorias(web: true),
          _secaoServicosRecentes(web: true),
          _secaoPrestadoresRecentes(web: true),
        ], 24),
      );
    }

    return ShellWeb(
      titulo: 'Início',
      rotaAtual: AppRoutes.home,
      acoes: [
        IconButton(
          tooltip: 'Atualizar',
          onPressed: _atualizarTudo,
          icon: const Icon(Icons.refresh),
        ),
        if (logado)
          IconButton(
            tooltip: 'Notificações',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.notificacoes),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConteudoCentralizado(
          larguraMax: 1200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BannerBoasVindas(nome: nome),
              const SizedBox(height: 24),
              corpo,
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Seções (devolvem null quando não há o que mostrar)
  // ---------------------------------------------------------------

  /// Remove os nulls e coloca [espaco] entre as seções visíveis.
  List<Widget> _empilhar(Iterable<Widget?> secoes, double espaco) {
    final visiveis = secoes.whereType<Widget>().toList();
    return [
      for (var i = 0; i < visiveis.length; i++) ...[
        if (i > 0) SizedBox(height: espaco),
        visiveis[i],
      ],
    ];
  }

  Widget _envolver(bool web, Widget conteudo) =>
      web ? _Painel(child: conteudo) : conteudo;

  Widget _cabecalhoSecao({
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

  Widget? _secaoAgendamentos({required bool web}) {
    if (!Sessao.instance.estaLogado) return null;

    final semConteudo =
        !_carregandoAgendamentos &&
        _erroAgendamentos == null &&
        _agendamentoCliente == null &&
        _agendamentoPrestador == null;
    if (semConteudo) return null;

    return _envolver(
      web,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cabecalhoSecao(
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
        AgendamentoProximoCard(
          nome: _agendamentoCliente!.prestadorNome,
          avatarUrl: _agendamentoCliente!.prestadorAvatarUrl,
          verificado: _agendamentoCliente!.prestadorVerificado,
          agendamento: _agendamentoCliente!.agendamento,
          subtitulo: 'Você contratou',
          onTap: () => _abrirAgendamento(_agendamentoCliente!.agendamento.id),
        ),
      if (_agendamentoPrestador != null)
        AgendamentoProximoCard(
          nome: _agendamentoPrestador!.clienteNome,
          avatarUrl: _agendamentoPrestador!.clienteAvatarUrl,
          verificado: _agendamentoPrestador!.clienteVerificado,
          agendamento: _agendamentoPrestador!.agendamento,
          subtitulo: 'Cliente agendou com você',
          onTap: () => _abrirAgendamento(_agendamentoPrestador!.agendamento.id),
        ),
    ];

    return Column(children: _empilhar(cards, 12));
  }

  Widget? _secaoCategorias({required bool web}) {
    final limite = web ? _maxCategoriasWeb : _maxCategoriasMobile;

    return _envolver(
      web,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cabecalhoSecao(
            titulo: 'Serviços disponíveis',
            aoTocarAcao: _categorias.length > limite
                ? () => Navigator.of(context).pushNamed(AppRoutes.categorias)
                : null,
          ),
          const SizedBox(height: 12),
          _buildCategorias(web: web, limite: limite),
        ],
      ),
    );
  }

  Widget _buildCategorias({required bool web, required int limite}) {
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

    final exibidas = _categorias.take(limite).toList();

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: web
          ? const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.95,
            )
          : const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
      children: [
        for (final categoria in exibidas)
          CategoriaCard(
            categoria: categoria,
            onTap: () => _abrirCategoria(categoria),
          ),
      ],
    );
  }

  Widget? _secaoServicosRecentes({required bool web}) {
    if (!Sessao.instance.estaLogado || _servicosRecentes.isEmpty) return null;

    final cards = [
      for (final servico in _servicosRecentes)
        ServicoRecenteCard(
          servico: servico,
          onTap: () => _abrirServicoRecente(servico),
        ),
    ];

    return _envolver(
      web,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cabecalhoSecao(titulo: 'Serviços recentes'),
          const SizedBox(height: 12),
          if (web)
            // ListView horizontal não rola com mouse na web: usa Wrap.
            Wrap(spacing: 12, runSpacing: 12, children: cards)
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => cards[i],
              ),
            ),
        ],
      ),
    );
  }

  Widget? _secaoPrestadoresRecentes({required bool web}) {
    if (!Sessao.instance.estaLogado || _prestadoresRecentes.isEmpty) {
      return null;
    }

    final cards = [
      for (final prestador in _prestadoresRecentes)
        PrestadorRecenteCard(
          prestador: prestador,
          onTap: () => _abrirPrestadorRecente(prestador),
        ),
    ];

    return _envolver(
      web,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cabecalhoSecao(titulo: 'Prestadores recentes'),
          const SizedBox(height: 12),
          if (web)
            Wrap(spacing: 8, runSpacing: 12, children: cards)
          else
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => cards[i],
              ),
            ),
        ],
      ),
    );
  }
}

/// Painel branco com borda fina, usado para agrupar seções no web.
class _Painel extends StatelessWidget {
  final Widget child;
  const _Painel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

/// Banner de boas-vindas do layout web.
class _BannerBoasVindas extends StatelessWidget {
  final String? nome;
  const _BannerBoasVindas({required this.nome});

  @override
  Widget build(BuildContext context) {
    final saudacao = nome != null ? 'Olá, $nome' : 'Bem-vindo';
    final semAgendamentoNaWeb = !Sessao.instance.permissoes.pode(
      Capacidade.criarAgendamento,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            saudacao,
            style: AppTextStyles.display.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Do que você precisa hoje?',
            style: AppTextStyles.corpo.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          if (semAgendamentoNaWeb) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.smartphone, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Para agendar um serviço, use o app Ajudaí.',
                  style: AppTextStyles.corpo.copyWith(color: Colors.white),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Cabeçalho mobile — fundo vermelho, cantos arredondados embaixo,
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
            if (Sessao.instance.estaLogado)
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
