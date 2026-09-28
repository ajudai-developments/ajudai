import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/widgets/grade_adaptativa.dart';
import 'package:ajudai/core/widgets/tela_adaptativa.dart';
import 'package:ajudai/features/perfil/widgets/modal_detalhe_servico.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/rating_display.dart';
import '../../core/widgets/user_avatar.dart';
import '../../core/ws/ws_message_stream.dart';
import '../conversas/conversas_repository.dart';
import '../usuario/usuario_repository.dart';
import 'widgets/cartao_servico_oferecido.dart';
import 'widgets/comentarios_list.dart';
import 'widgets/selos_destaque.dart';

/// Perfil público de um usuário — visualização somente leitura.
///
/// Recebe `usuarioId` via argumento da rota e busca o perfil público
/// direto do backend. Os comentários exibidos aqui são sobre o usuário
/// em si (`AvaliacaoUsuario`), não sobre serviços específicos — o
/// backend deixou de expor avaliações de serviço separadas no perfil.
class PerfilPublicoScreen extends StatefulWidget {
  const PerfilPublicoScreen({super.key});

  @override
  State<PerfilPublicoScreen> createState() => _PerfilPublicoScreenState();
}

class _PerfilPublicoScreenState extends State<PerfilPublicoScreen> {
  final _usuarioRepository = UsuarioRepository();
  final _conversasRepository = ConversasRepository();

  late String _usuarioId;
  bool _argumentosCarregados = false;

  bool _carregando = true;
  String? _erro;
  ObterPerfilPublicoResponseDto? _dados;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;

    _usuarioId = ModalRoute.of(context)!.settings.arguments as String;
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final dados = await _usuarioRepository.obterPerfilPublico(
        usuarioId: _usuarioId,
      );
      setState(() => _dados = dados);
    } on WsErroException catch (e) {
      setState(() {
        _erro = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() {
        _erro = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _conversar() async {
    final usuario = _dados?.usuario;
    if (usuario == null) return;

    try {
      final conversaId = await _conversasRepository.criarConversa(usuario.id);
      final conversas = await _conversasRepository.listarConversas();
      final conversa = conversas.firstWhere(
        (item) => item.conversaId == conversaId,
      );
      if (!mounted) return;
      await Navigator.of(
        context,
      ).pushNamed(AppRoutes.conversa, arguments: conversa);
    } on WsErroException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem),
          ),
        ),
      );
    } on WsTimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível iniciar a conversa.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dados = _dados;
    final web = context.usaLayoutWeb;

    return TelaAdaptativa(
      titulo: dados?.usuario.nome ?? 'Perfil',
      rotaAtual: AppRoutes.perfilPublico,
      semAppBarMobile: true,
      child: web ? _corpoWeb(dados) : _corpoMobile(dados),
    );
  }

  Widget _corpoWeb(ObterPerfilPublicoResponseDto? dados) {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    Widget conteudo(ObterPerfilPublicoResponseDto d) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [..._secaoServicos(d, web: true), ..._secaoComentarios(d)],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConteudoCentralizado(
        larguraMax: 1100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ErrorBanner(mensagem: _erro),
            if (dados != null)
              context.ehDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 340,
                          child: Column(
                            children: [
                              _Cabecalho(
                                dados: dados,
                                carregando: false,
                                comoCartao: true,
                              ),
                              const SizedBox(height: 16),
                              _botaoConversar(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(child: conteudo(dados)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Cabecalho(
                          dados: dados,
                          carregando: false,
                          comoCartao: true,
                        ),
                        const SizedBox(height: 16),
                        _botaoConversar(),
                        const SizedBox(height: 28),
                        conteudo(dados),
                      ],
                    ),
          ],
        ),
      ),
    );
  }

  Widget _corpoMobile(ObterPerfilPublicoResponseDto? dados) {
    return Column(
      children: [
        _Cabecalho(dados: dados, carregando: _carregando),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _carregar,
            child: _carregando
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    children: [
                      ErrorBanner(mensagem: _erro),
                      if (dados != null) ...[
                        ..._secaoServicos(dados, web: false),
                        _botaoConversar(),
                        const SizedBox(height: 28),
                        ..._secaoComentarios(dados),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _mensagemVazia(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        texto,
        style: AppTextStyles.corpo,
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Widget> _secaoServicos(
    ObterPerfilPublicoResponseDto dados, {
    required bool web,
  }) {
    if (!dados.ehPrestador) return const [];

    final cartoes = [
      for (final servico in dados.servicosOferecidos)
        CartaoServicoOferecido(
          servico: servico,
          onTap: () => abrirModalDetalheServico(
            context: context,
            servicoOferecidoId: servico.servicoOferecidoId,
            prestadorId: dados.usuario.id,
          ),
        ),
    ];

    return [
      _SecaoTitulo('Serviços oferecidos'),
      const SizedBox(height: 10),
      if (cartoes.isEmpty)
        _mensagemVazia('Nenhum serviço oferecido cadastrado.')
      else if (web)
        GradeAdaptativa(
          larguraMinItem: 300,
          maxColunas: 2,
          espaco: 12,
          children: cartoes,
        )
      else
        Column(
          children: [
            for (final c in cartoes)
              Padding(padding: const EdgeInsets.only(bottom: 10), child: c),
          ],
        ),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _secaoComentarios(ObterPerfilPublicoResponseDto dados) => [
    _SecaoTitulo('Comentários'),
    const SizedBox(height: 10),
    ComentariosList(comentarios: dados.comentariosUsuario),
  ];

  Widget _botaoConversar() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _conversar,
        icon: const Icon(Icons.chat_bubble_rounded, size: 18),
        label: const Text('Conversar'),
      ),
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String texto;

  const _SecaoTitulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(texto, style: AppTextStyles.titulo);
  }
}

/// Cabeçalho do perfil público — mesmo padrão vermelho arredondado usado
/// na Home e em Meu Perfil (CabecalhoComAbas), com avatar, nome, selo de
/// verificado, avaliação (se for prestador) e selos de conquista.
///
/// Fica sempre visível (inclusive durante o loading, com placeholders),
/// diferente do card branco solto de antes — dá identidade à tela desde
/// o primeiro frame em vez de abrir em branco.
class _Cabecalho extends StatelessWidget {
  final ObterPerfilPublicoResponseDto? dados;
  final bool carregando;
  final bool comoCartao;

  const _Cabecalho({
    required this.dados,
    required this.carregando,
    this.comoCartao = false,
  });

  @override
  Widget build(BuildContext context) {
    final usuario = dados?.usuario;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: comoCartao
            ? BorderRadius.circular(20)
            : const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
      ),
      padding: EdgeInsets.only(
        top: comoCartao ? 0 : MediaQuery.of(context).padding.top,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, comoCartao ? 24 : 4, 12, 24),
        child: Column(
          children: [
            if (!comoCartao)
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: UserAvatar(avatarUrl: usuario?.avatarUrl, radius: 38),
            ),
            const SizedBox(height: 12),
            Text(
              usuario?.nome ?? (carregando ? 'Carregando...' : 'Perfil'),
              style: AppTextStyles.display.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (usuario != null && usuario.verificado) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Verificado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (dados != null && dados!.ehPrestador) ...[
              const SizedBox(height: 10),
              RatingDisplay(
                media: dados!.mediaAvaliacaoUsuario,
                quantidadeAvaliacoes: dados!.quantidadeAvaliacoesUsuario,
                cor: Colors.white,
              ),
              const SizedBox(height: 4),
              Text(
                '${dados!.quantidadeServicosConcluidos} serviços concluídos',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
            if (dados != null && dados!.selos.isNotEmpty) ...[
              const SizedBox(height: 16),
              SelosDestaque(selos: dados!.selos, sobreFundoEscuro: true),
            ],
          ],
        ),
      ),
    );
  }
}
