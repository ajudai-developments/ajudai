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

  @override
  Widget build(BuildContext context) {
    final usuario = Sessao.instance.usuario;

    if (usuario == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Meu perfil')),
        body: const Center(child: Text('Sessão não encontrada.')),
      );
    }

    final selos = _perfilCompleto?.conquistas ?? <ConquistaUsuario>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _PerfilHeader(
            usuario: usuario,
            perfilCompleto: _perfilCompleto,
            carregando: _carregandoPerfilCompleto,
            selos: selos,
            onEditar: _abrirEdicao,
            onVerMais: () =>
                Navigator.of(context).pushNamed(AppRoutes.meuPerfilCompleto),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _carregarPerfilCompleto,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
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
                        subtitulo:
                            'Acompanhe contestações abertas em agendamentos',
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.minhasContestacoes),
                      ),
                      const Divider(height: 1, color: AppColors.outline),
                      _AcaoItem(
                        icone: Icons.flag_rounded,
                        cor: AppColors.error,
                        titulo: 'Minhas denúncias',
                        subtitulo:
                            'Veja o andamento das denúncias que você fez',
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.minhasDenuncias),
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
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.meusEnderecos),
                      ),
                      const Divider(height: 1, color: AppColors.outline),
                      _AcaoItem(
                        icone: Icons.chat_bubble_rounded,
                        cor: AppColors.primary,
                        titulo: 'Conversas',
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.conversas),
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
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
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
          _avisoStatus('Sua solicitação para ser prestador está em análise.'),
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

/// Cabeçalho da tela de perfil — fundo vermelho arredondado (mesmo
/// padrão de CabecalhoComAbas/Home), com avatar sobreposto, nome, selo
/// de verificado, selos de conquista e avaliação.
class _PerfilHeader extends StatelessWidget {
  final Usuario usuario;
  final PerfilCompleto? perfilCompleto;
  final bool carregando;
  final List<ConquistaUsuario> selos;
  final VoidCallback onEditar;
  final VoidCallback onVerMais;

  const _PerfilHeader({
    required this.usuario,
    required this.perfilCompleto,
    required this.carregando,
    required this.selos,
    required this.onEditar,
    required this.onVerMais,
  });

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.fromLTRB(20, 8, 12, 24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: UserAvatar(avatarUrl: usuario.avatarUrl, radius: 38),
            ),
            const SizedBox(height: 12),
            Text(
              usuario.nome,
              style: AppTextStyles.display.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            if (usuario.verificado)
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
            if (carregando)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            else if (perfilCompleto != null) ...[
              const SizedBox(height: 10),
              RatingDisplay(
                media: perfilCompleto!.mediaAvaliacao,
                quantidadeAvaliacoes: perfilCompleto!.totalAvaliacoes,
                cor: Colors.white,
              ),
            ],
            if (!carregando && selos.isNotEmpty) ...[
              const SizedBox(height: 10),
              SelosDestaque(selos: selos, sobreFundoEscuro: true),
            ],
            const SizedBox(height: 4),
            TextButton(
              onPressed: onVerMais,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Ver mais'),
            ),
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
