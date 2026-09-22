import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/session/sessao.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_button.dart';
import '../auth/auth_repository.dart';

/// Perfil do PRÓPRIO usuário logado — dados vêm direto de
/// `Sessao.instance.usuario` (populado no login/cadastro), sem chamada
/// de rede própria.
///
/// Seções condicionais:
/// - cliente sem solicitação de prestador -> botão "Quero ser prestador".
/// - cliente com solicitação pendente/aprovada/suspensa -> aviso de status.
/// - prestador -> link pra "Meus serviços oferecidos" (sem o botão
///   acima, que não faz sentido pra quem já é prestador).
class MeuPerfilScreen extends StatefulWidget {
  const MeuPerfilScreen({super.key});

  @override
  State<MeuPerfilScreen> createState() => _MeuPerfilScreenState();
}

class _MeuPerfilScreenState extends State<MeuPerfilScreen> {
  Future<void> _abrirEdicao() async {
    await Navigator.of(context).pushNamed(AppRoutes.editarPerfil);
    // UsuarioRepository.atualizarPerfil já atualiza a Sessao sozinho;
    // só precisamos forçar este widget a reconstruir e reler o valor
    // atual — não importa se a edição foi salva ou cancelada, reler é
    // inofensivo nos dois casos.
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
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Sessao.instance.usuario;

    // Não deveria acontecer (só se chega aqui autenticado), mas evita
    // um crash feio caso a sessão tenha sido limpa por algum motivo.
    if (usuario == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Meu perfil')),
        body: const Center(child: Text('Sessão não encontrada.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu perfil'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _abrirEdicao),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 16),
            Text(
              usuario.nome,
              style: AppTextStyles.titulo,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            if (usuario.verificado)
              const Center(
                child: Chip(
                  avatar: Icon(Icons.verified, size: 16, color: Colors.white),
                  label: Text(
                    'Verificado',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppColors.success,
                ),
              ),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.meuPerfilCompleto),
                child: const Text('Ver mais'),
              ),
            ),
            const SizedBox(height: 24),
            _linha('Telefone', usuario.telefone ?? 'Não informado'),
            const SizedBox(height: 24),
            ..._buildSecaoPrestador(context, usuario),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.meusEnderecos),
              child: const Text('Meus endereços'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.conversas),
              child: const Text('Conversas'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.meusAgendamentos),
              child: const Text('Meus agendamentos'),
            ),
            if (usuario.userRole == UserRole.prestador) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.agendamentosRecebidos),
                child: const Text('Agendamentos recebidos'),
              ),
            ],
            const SizedBox(height: 32),
            TextButton(onPressed: _sair, child: const Text('Sair da conta')),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Widget _linha(String label, String valor) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: AppTextStyles.legenda)),
        Expanded(child: Text(valor, style: AppTextStyles.corpo)),
      ],
    );
  }

  List<Widget> _buildSecaoPrestador(BuildContext context, Usuario usuario) {
    if (usuario.userRole == UserRole.prestador) {
      return [
        AppButton(
          label: 'Meus serviços oferecidos',
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.meusServicosOferecidos),
        ),
      ];
    }

    // Cliente: o que mostrar depende do status da solicitação de prestador.
    switch (usuario.statusPrestador) {
      case StatusPrestador.naoSolicitado:
        return [
          AppButton(
            label: 'Quero ser prestador',
            onPressed: _abrirSolicitarPrestador,
          ),
        ];
      case StatusPrestador.pendente:
        return [
          _avisoStatus('Sua solicitação para ser prestador está em análise.'),
        ];
      case StatusPrestador.aprovado:
        // Caso de borda: aprovado mas userRole ainda não é prestador
        // (não deveria persistir, mas evita não mostrar nada).
        return [
          _avisoStatus('Solicitação aprovada! Atualize o app se necessário.'),
        ];
      case StatusPrestador.suspenso:
        return [_avisoStatus('Sua conta de prestador está suspensa.')];
    }
  }

  Widget _avisoStatus(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(texto, style: AppTextStyles.corpo),
    );
  }
}
