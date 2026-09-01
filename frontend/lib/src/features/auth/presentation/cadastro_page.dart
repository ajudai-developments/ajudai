import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../state/auth_controller.dart';
import '../state/auth_state.dart';
import 'widgets/cadastro_form.dart';

class CadastroPage extends ConsumerWidget {
  const CadastroPage({super.key});

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
              content: Text('Conta criada com sucesso, ${atual.usuario.nome}!'),
              backgroundColor: AppColors.verde,
            ),
          );
      }
    });

    return Scaffold(
      appBar: AppBar(),
      body: LoadingOverlay(
        visivel: carregando,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Criar conta', style: AppTextStyles.titulo),
                const SizedBox(height: 8),
                const Text(
                  'Preencha seus dados para começar',
                  style: AppTextStyles.subtitulo,
                ),
                const SizedBox(height: 32),
                CadastroForm(
                  carregando: carregando,
                  onSubmit:
                      ({
                        required nome,
                        required email,
                        required senha,
                        required cpf,
                        telefone,
                      }) => ref
                          .read(authControllerProvider.notifier)
                          .cadastrar(
                            nome: nome,
                            email: email,
                            senha: senha,
                            cpf: cpf,
                            telefone: telefone,
                          ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
