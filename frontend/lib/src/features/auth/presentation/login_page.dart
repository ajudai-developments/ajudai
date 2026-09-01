import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../state/auth_controller.dart';
import '../state/auth_state.dart';
import 'cadastro_page.dart';
import 'widgets/login_form.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final carregando = state is AuthCarregando;

    ref.listen<AuthState>(authControllerProvider, (anterior, atual) {
      if (atual is AuthErro) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(atual.mensagem)));
      }
      if (atual is AuthAutenticado) {
        // TODO: navegar para a home do app quando ela existir.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Bem-vindo(a), ${atual.usuario.nome}!'),
              backgroundColor: AppColors.verde,
            ),
          );
      }
    });

    return Scaffold(
      body: LoadingOverlay(
        visivel: carregando,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text('Bem-vindo de volta', style: AppTextStyles.titulo),
                const SizedBox(height: 8),
                const Text(
                  'Entre com sua conta para continuar',
                  style: AppTextStyles.subtitulo,
                ),
                const SizedBox(height: 36),
                LoginForm(
                  carregando: carregando,
                  onSubmit: (email, senha) => ref
                      .read(authControllerProvider.notifier)
                      .login(email: email, senha: senha),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Ainda não tem conta?', style: AppTextStyles.secundario),
                    TextButton(
                      onPressed: carregando
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CadastroPage()),
                              ),
                      child: const Text('Cadastre-se'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
