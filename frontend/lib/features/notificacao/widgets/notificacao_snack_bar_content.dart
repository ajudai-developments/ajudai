// features/notificacao/widgets/notificacao_snackbar_content.dart
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Conteúdo do snackbar de notificação — a aparência (ícone e cor)
/// varia conforme a categoria, mas o layout (ícone + título + mensagem)
/// é compartilhado entre todas.
class NotificacaoSnackBarContent extends StatelessWidget {
  final NotificacaoDto notificacao;

  const NotificacaoSnackBarContent({required this.notificacao, super.key});

  @override
  Widget build(BuildContext context) {
    final (icone, cor) = switch (notificacao.categoria) {
      CategoriaNotificacao.agendamento => (
        Icons.calendar_today_rounded,
        Colors.blueAccent,
      ),
      CategoriaNotificacao.conversa => (
        Icons.chat_bubble_rounded,
        Colors.green,
      ),
      CategoriaNotificacao.geral => (
        Icons.notifications_rounded,
        Colors.grey.shade400,
      ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: cor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notificacao.titulo,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(notificacao.mensagem, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}
