import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/widgets/tela_adaptativa.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/session/sessao.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/rating_display.dart';
import '../../core/widgets/user_avatar.dart';
import '../auth/auth_repository.dart';
import '../perfil/widgets/selos_destaque.dart';
import 'usuario_repository.dart';

/// Tela "Meu perfil".
///
/// Layout, de cima pra baixo:
/// 1. Cabeçalho vermelho arredondado (mesmo padrão visual de
///    CabecalhoComAbas/Home) com avatar, nome, selo de verificado,
///    avaliação e botão de editar.
/// 2. Card de informações básicas (telefone).
/// 3. Bloco de prestador — varia conforme status (ver
///    _buildSecaoPrestador).
/// 4. Central de suporte — Minhas contestações / Minhas denúncias.
///    Fica aqui (e não na Home) porque são recursos "sobre o usuário",
///    junto com o resto do perfil.
/// 5. Outras ações (endereços, conversas).
/// 6. Sair da conta.
class MeuPerfilScreen extends StatefulWidget {
  const MeuPerfilScreen({super.key});

  @override
  State<MeuPerfilScreen> createState() => _MeuPerfilScreenState();
}

class _MeuPerfilScreenState extends State<MeuPerfilScreen> {
  final _usuarioRepository = UsuarioRepository();

  PerfilCompleto? _perfilCompleto;
  bool _carregandoPerfilCompleto = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfilCompleto();
  }

  Future<void> _carregarPerfilCompleto() async {
    try {
      final perfil = await _usuarioRepository.obterPerfilCompleto();
      await AuthRepository().restaurarSessao();
      if (mounted) setState(() => _perfilCompleto = perfil);
    } catch (_) {
      // Selos e avaliação são extras visuais — se a busca falhar, a
      // tela segue funcionando normalmente, só sem essas seções.
    } finally {
      if (mounted) setState(() => _carregandoPerfilCompleto = false);
    }
  }

  Future<void> _abrirEdicao() async {
    await Navigator.of(context).pushNamed(AppRoutes.editarPerfil);
    if (mounted) setState(() {});
  }

  Future<void> _abrirSolicitarPrestador() async {
    await Navigator.of(context).pushNamed(AppRoutes.solicitarPrestador);
    if (mounted) setState(() {});
  }

  Future<void> _sair() async {
    await AuthRepository().logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  Future<void> _abrirMinhaSolicitacao() async {
    await Navigator.of(context).pushNamed(AppRoutes.minhaSolicitacaoPrestador);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Sessao.instance.usuario;
    final web = context.usaLayoutWeb;

    if (usuario == null) {
      return const TelaAdaptativa(
        titulo: 'Meu perfil',
        rotaAtual: AppRoutes.meuPerfil,
        child: Center(child: Text('Sessão não encontrada.')),
      );
    }

    final header = _PerfilHeader(
      usuario: usuario,
      perfilCompleto: _perfilCompleto,
      carregando: _carregandoPerfilCompleto,
      selos: _perfilCompleto?.conquistas ?? <ConquistaUsuario>[],
      onEditar: _abrirEdicao,
      onVerMais: () =>
          Navigator.of(context).pushNamed(AppRoutes.meuPerfilCompleto),
      comoCartao: web,
    );

    return ListenableBuilder(
      listenable: Sessao.instance,
      builder: (context, _) => TelaAdaptativa(
        titulo: 'Meu perfil',
        rotaAtual: AppRoutes.meuPerfil,
        semAppBarMobile: true,
        rodapeMobile: const AppBottomNav(currentIndex: 2),
        child: web ? _corpoWeb(usuario, header) : _corpoMobile(usuario, header),
      ),
    );
  }

  Widget _corpoMobile(Usuario usuario, Widget header) {
    return Column(
      children: [
        header,
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _carregarPerfilCompleto,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: _secoes(usuario),
            ),
          ),
        ),
      ],
    );
  }

  Widget _corpoWeb(Usuario usuario, Widget header) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConteudoCentralizado(
        larguraMax: 1100,
        child: context.ehDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 340, child: header),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _secoes(usuario),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const SizedBox(height: 24),
                  ..._secoes(usuario),
                ],
              ),
      ),
    );
  }

  /// Tudo que vem abaixo do cabeçalho — igual nos dois layouts.
  List<Widget> _secoes(Usuario usuario) {
    if (usuario.statusUsuario) {
      return [
        const _AvisoBanido(),
        const SizedBox(height: 20),
        _SecaoCard(
          children: [
            _LinhaInfo(
              icone: Icons.phone_rounded,
              label: 'Telefone',
              valor: usuario.telefone ?? 'Não informado',
            ),
          ],
        ),
        const SizedBox(height: 32),
        Center(
          child: TextButton.icon(
            onPressed: _sair,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sair da conta'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textoSecundario,
            ),
          ),
        ),
      ];
    }
    return [
      _SecaoCard(
        children: [
          _LinhaInfo(
            icone: Icons.phone_rounded,
            label: 'Telefone',
            valor: usuario.telefone ?? 'Não informado',
          ),
        ],
      ),
      const SizedBox(height: 20),
      ..._buildSecaoPrestador(context, usuario),
      Text('Central de suporte', style: AppTextStyles.titulo),
      const SizedBox(height: 12),
      _SecaoCard(
        children: [
          _AcaoItem(
            icone: Icons.gavel_rounded,
            cor: AppColors.warning,
            titulo: 'Minhas contestações',
            subtitulo: 'Acompanhe contestações abertas em agendamentos',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.minhasContestacoes),
          ),
          const Divider(height: 1, color: AppColors.outline),
          _AcaoItem(
            icone: Icons.flag_rounded,
            cor: AppColors.error,
            titulo: 'Minhas denúncias',
            subtitulo: 'Veja o andamento das denúncias que você fez',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.minhasDenuncias),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Text('Mais', style: AppTextStyles.titulo),
      const SizedBox(height: 12),
      _SecaoCard(
        children: [
          _AcaoItem(
            icone: Icons.location_on_rounded,
            cor: AppColors.primary,
            titulo: 'Meus endereços',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.meusEnderecos),
          ),
          const Divider(height: 1, color: AppColors.outline),
          _AcaoItem(
            icone: Icons.chat_bubble_rounded,
            cor: AppColors.primary,
            titulo: 'Conversas',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.conversas),
          ),
        ],
      ),
      const SizedBox(height: 32),
      Center(
        child: TextButton.icon(
          onPressed: _sair,
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Sair da conta'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textoSecundario,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSecaoPrestador(BuildContext context, Usuario usuario) {
    if (usuario.userRole == UserRole.prestador) {
      return [
        Text('Prestador', style: AppTextStyles.titulo),
        const SizedBox(height: 12),
        _SecaoCard(
          children: [
            _AcaoItem(
              icone: Icons.design_services_rounded,
              cor: AppColors.primary,
              titulo: 'Meus serviços oferecidos',
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.meusServicosOferecidos),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ];
    }

    switch (usuario.statusPrestador) {
      case StatusPrestador.naoSolicitado:
        return [
          _SecaoCard(
            children: [
              _AcaoItem(
                icone: Icons.workspace_premium_rounded,
                cor: AppColors.primary,
                titulo: 'Quero ser prestador',
                onTap: _abrirSolicitarPrestador,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ];
      case StatusPrestador.pendente:
        return [
          _SecaoCard(
            children: [
              _AcaoItem(
                icone: Icons.hourglass_top_rounded,
                cor: AppColors.warning,
                titulo: 'Solicitação em análise',
                subtitulo: 'Toque para acompanhar',
                onTap: _abrirMinhaSolicitacao,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ];
      case StatusPrestador.rejeitado:
        return [
          _SecaoCard(
            children: [
              _AcaoItem(
                icone: Icons.cancel_rounded,
                cor: AppColors.error,
                titulo: 'Solicitação rejeitada',
                subtitulo: 'Veja o motivo e tente novamente',
                onTap: _abrirMinhaSolicitacao,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ];
      case StatusPrestador.aprovado:
        return [
          _avisoStatus('Solicitação aprovada! Atualize o app se necessário.'),
          const SizedBox(height: 20),
        ];
      case StatusPrestador.suspenso:
        return [
          _avisoStatus('Sua conta de prestador está suspensa.'),
          const SizedBox(height: 20),
        ];
    }
  }

  Widget _avisoStatus(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: AppTextStyles.corpo)),
        ],
      ),
    );
  }
}

class _PerfilHeader extends StatelessWidget {
  final Usuario usuario;
  final PerfilCompleto? perfilCompleto;
  final bool carregando;
  final List<ConquistaUsuario> selos;
  final VoidCallback onEditar;
  final VoidCallback onVerMais;
  final bool comoCartao;

  const _PerfilHeader({
    required this.usuario,
    required this.perfilCompleto,
    required this.carregando,
    required this.selos,
    required this.onEditar,
    required this.onVerMais,
    this.comoCartao = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: comoCartao
            ? BorderRadius.circular(20)
            : const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
      ),
      padding: EdgeInsets.only(
        top: comoCartao ? 0 : MediaQuery.of(context).padding.top,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, comoCartao ? 20 : 12, 8, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Área clicável: avatar + nome → perfil completo
                Expanded(
                  child: InkWell(
                    onTap: onVerMais,
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: UserAvatar(
                            avatarUrl: usuario.avatarUrl,
                            radius: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      usuario.nome,
                                      style: AppTextStyles.display.copyWith(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 10,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (usuario.verificado)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.18,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.verified,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Verificado',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (carregando)
                                    const SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  else if (perfilCompleto != null)
                                    RatingDisplay(
                                      media: perfilCompleto!.mediaAvaliacao,
                                      quantidadeAvaliacoes:
                                          perfilCompleto!.totalAvaliacoes,
                                      cor: Colors.white,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!usuario.statusUsuario)
                  IconButton(
                    onPressed: onEditar,
                    tooltip: 'Editar perfil',
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  ),
              ],
            ),
            if (!carregando && selos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SelosDestaque(selos: selos, sobreFundoEscuro: true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Container branco arredondado que agrupa itens de _AcaoItem/_LinhaInfo
/// — o "card" reutilizado nas seções da tela.
class _SecaoCard extends StatelessWidget {
  final List<Widget> children;
  const _SecaoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(children: children),
    );
  }
}

/// Linha de informação estática (não clicável) dentro de um _SecaoCard.
class _LinhaInfo extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;

  const _LinhaInfo({
    required this.icone,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icone, color: AppColors.textoSecundario, size: 20),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.legenda),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: AppTextStyles.corpo.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha clicável (ícone em círculo colorido + título [+ subtítulo] +
/// chevron) dentro de um _SecaoCard.
class _AcaoItem extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;

  const _AcaoItem({
    required this.icone,
    required this.cor,
    required this.titulo,
    this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: cor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppTextStyles.corpo.copyWith(
                      color: AppColors.textoTitulo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitulo!, style: AppTextStyles.legenda),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textoSecundario,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoBanido extends StatelessWidget {
  const _AvisoBanido();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.block_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você está banido da plataforma',
                  style: AppTextStyles.corpo.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Você não pode mais agendar serviços, conversar ou '
                  'oferecer serviços.',
                  style: AppTextStyles.legenda,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
