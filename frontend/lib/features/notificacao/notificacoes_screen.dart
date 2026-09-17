import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/async_list_view.dart';
import 'notificacao_repository.dart';

/// Lista as notificações do usuário.
///
/// Sem data, sem indicador de lida/não-lida — o DTO não carrega esses
/// dados (ver notificacao_repository.dart). A ordem exibida é a que o
/// servidor mandar.
class NotificacoesScreen extends StatelessWidget {
  const NotificacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = NotificacaoRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notificações')),
      body: AsyncListView<NotificacaoDto>(
        carregar: repository.listarMinhasNotificacoes,
        mensagemVazio: 'Você não tem notificações.',
        builder: (context, notificacoes) => Column(
          children: [
            for (final notificacao in notificacoes)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: Text(notificacao.titulo, style: AppTextStyles.titulo),
                  subtitle: Text(
                    notificacao.mensagem,
                    style: AppTextStyles.corpo,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
