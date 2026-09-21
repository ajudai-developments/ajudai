import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/app_text_styles.dart';

/// Pop-up exibido quando o usuário tenta acessar uma área que exige
/// login (Agenda, Perfil) sem ter uma sessão ativa.
///
/// Este widget só cuida de MOSTRAR o aviso e levar o usuário para
/// login/cadastro — não decide sozinho quando aparecer. Quem chama
/// continua responsável por checar `Sessao.instance.estaLogado` antes
/// de abrir o diálogo (ver AppBottomNav, próximo arquivo).
class LoginNecessarioDialog extends StatelessWidget {
  const LoginNecessarioDialog({super.key});

  /// Atalho pra abrir o diálogo.
  static Future<void> mostrar(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const LoginNecessarioDialog(),
    );
  }

  void _irPara(BuildContext context, String rota) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(rota);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Entre na sua conta', style: AppTextStyles.titulo),
      content: Text(
        'Você precisa estar logado para acessar essa área.',
        style: AppTextStyles.corpo,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Agora não'),
        ),
        TextButton(
          onPressed: () => _irPara(context, AppRoutes.cadastro),
          child: const Text('Cadastrar'),
        ),
        ElevatedButton(
          onPressed: () => _irPara(context, AppRoutes.login),
          child: const Text('Entrar'),
        ),
      ],
    );
  }
}
