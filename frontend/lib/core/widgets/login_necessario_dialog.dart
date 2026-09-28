import 'package:ajudai/core/session/sessao.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Bottom sheet exibido quando o usuário tenta acessar uma área que exige
/// login (Agenda, Perfil, Pedidos) sem ter uma sessão ativa.
///
/// Este widget só cuida de MOSTRAR o aviso e levar o usuário para
/// login/cadastro — não decide sozinho quando aparecer. Quem chama
/// continua responsável por checar `Sessao.instance.estaLogado` antes
/// de abrir (ver AppBottomNav).
class LoginNecessarioDialog extends StatelessWidget {
  final String mensagem;

  const LoginNecessarioDialog({
    super.key,
    this.mensagem =
        'Acesse sua conta ou crie uma nova para ver sua agenda, '
        'seu perfil e seus pedidos.',
  });

  /// Atalho pra abrir o sheet.
  static Future<void> mostrar(BuildContext context, {String? mensagem}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => mensagem == null
          ? const LoginNecessarioDialog()
          : LoginNecessarioDialog(mensagem: mensagem),
    );
  }

  void _irPara(BuildContext context, String rota) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed(rota);
  }

  static bool exigir(BuildContext context, {String? mensagem}) {
    if (Sessao.instance.estaLogado) return true;
    mostrar(context, mensagem: mensagem);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Alça do sheet
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Ícone em destaque
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Entre para continuar',
              textAlign: TextAlign.center,
              style: AppTextStyles.display.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Acesse sua conta ou crie uma nova para ver sua agenda, '
              'seu perfil e seus pedidos.',
              textAlign: TextAlign.center,
              style: AppTextStyles.corpo,
            ),
            const SizedBox(height: 28),

            // Ação principal
            ElevatedButton(
              onPressed: () => _irPara(context, AppRoutes.login),
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 10),

            // Ação secundária
            OutlinedButton(
              onPressed: () => _irPara(context, AppRoutes.cadastro),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('Criar conta'),
            ),
            const SizedBox(height: 4),

            // Dispensar
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textoSecundario,
              ),
              child: const Text('Agora não'),
            ),
          ],
        ),
      ),
    );
  }
}
