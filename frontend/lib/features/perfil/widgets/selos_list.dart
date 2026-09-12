import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Lista de selos (conquistas) de um usuário, como chips.
///
/// Reutilizado em servico_detalhe_screen e perfil_publico_screen.
class SelosList extends StatelessWidget {
  final List<ConquistaUsuario> selos;

  const SelosList({super.key, required this.selos});

  @override
  Widget build(BuildContext context) {
    if (selos.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final selo in selos)
          Chip(
            avatar: const Icon(Icons.emoji_events, size: 18),
            label: Text(selo.conquista.nome),
          ),
      ],
    );
  }
}