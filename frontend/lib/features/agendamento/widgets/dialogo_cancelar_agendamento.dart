import 'package:flutter/material.dart';

/// Diálogo pedindo o motivo do cancelamento. Retorna o motivo digitado,
/// ou `null` se o usuário desistiu.
Future<String?> mostrarDialogoCancelarAgendamento(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancelar agendamento'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Por favor, conte o motivo do cancelamento:'),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Motivo',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Voltar'),
        ),
        FilledButton(
          onPressed: () {
            final motivo = controller.text.trim();
            if (motivo.isEmpty) return;
            Navigator.of(context).pop(motivo);
          },
          child: const Text('Confirmar cancelamento'),
        ),
      ],
    ),
  );
}
