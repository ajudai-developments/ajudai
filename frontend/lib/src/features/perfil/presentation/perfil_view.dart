import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/state/auth_controller.dart';
import '../../auth/state/auth_state.dart';
import '../state/perfil_providers.dart';
import 'endereco_form_page.dart';
import 'tornar_prestador_page.dart';
import 'widgets/endereco_card.dart';

/// Conteúdo da aba "Perfil". Sem Scaffold/AppBar próprios: é embutido
/// no shell da HomePage, que já fornece AppBar e bottom nav.
class PerfilView extends ConsumerWidget {
  const PerfilView({super.key});

  Future<void> _confirmarSaida(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await ref.read(authControllerProvider.notifier).sair();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final usuario = authState is AuthAutenticado ? authState.usuario : null;
    final enderecosAsync = ref.watch(meusEnderecosProvider);

    if (usuario == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(meusEnderecosProvider);
        await ref.read(meusEnderecosProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Cabecalho(usuario: usuario),
          const SizedBox(height: 28),
          Text(
            'Meus endereços',
            style: AppTextStyles.titulo.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          enderecosAsync.when(
            data: (enderecos) => Column(
              children: [
                if (enderecos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Você ainda não cadastrou nenhum endereço.'),
                  ),
                for (final endereco in enderecos)
                  EnderecoCard(
                    endereco: endereco,
                    onEditar: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              EnderecoFormPage(enderecoParaEditar: endereco),
                        ),
                      );
                    },
                  ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (erro, _) =>
                Text('Não foi possível carregar seus endereços.\n$erro'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EnderecoFormPage()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar endereço'),
          ),
          const SizedBox(height: 28),
          _SecaoPrestador(usuario: usuario),
          const SizedBox(height: 28),
          TextButton.icon(
            onPressed: () => _confirmarSaida(context, ref),
            icon: const Icon(Icons.logout, color: AppColors.erro),
            label: const Text('Sair', style: TextStyle(color: AppColors.erro)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final Usuario usuario;
  const _Cabecalho({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.vermelho.withValues(alpha: 0.1),
          child: Text(
            usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : '?',
            style: AppTextStyles.titulo.copyWith(color: AppColors.vermelho),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usuario.nome,
                style: AppTextStyles.titulo.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              if (usuario.telefone != null)
                Text(usuario.telefone!, style: AppTextStyles.secundario),
              if (usuario.userRole == UserRole.prestador) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      usuario.verificado
                          ? Icons.verified
                          : Icons.hourglass_bottom,
                      size: 16,
                      color: usuario.verificado
                          ? AppColors.verde
                          : AppColors.cinzaClaro,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      usuario.verificado
                          ? 'Prestador verificado'
                          : 'Verificação pendente',
                      style: AppTextStyles.secundario,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SecaoPrestador extends StatelessWidget {
  final Usuario usuario;
  const _SecaoPrestador({required this.usuario});

  @override
  Widget build(BuildContext context) {
    if (usuario.userRole == UserRole.prestador) {
      // TODO: navegar para a página de configuração de serviços oferecidos
      // quando ela existir.
      return OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuração de serviços em breve')),
          );
        },
        icon: const Icon(Icons.design_services_outlined),
        label: const Text('Meus serviços oferecidos'),
      );
    }

    switch (usuario.statusPrestador) {
      case StatusPrestador.pendente:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.fundoCampo,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Icon(Icons.hourglass_bottom, color: AppColors.cinzaEscuro),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sua solicitação para ser prestador está em análise.',
                ),
              ),
            ],
          ),
        );
      case StatusPrestador.suspenso:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.erro.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Seu cadastro como prestador está suspenso. Entre em contato com o suporte.',
            style: TextStyle(color: AppColors.erro),
          ),
        );
      case StatusPrestador.naoSolicitado:
      case StatusPrestador.aprovado:
        return ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TornarPrestadorPage()),
            );
          },
          child: const Text('QUERO SER PRESTADOR'),
        );
    }
  }
}
