import 'package:flutter/material.dart';

class PrestadorAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String nome;
  final bool verificado;

  const PrestadorAvatar({
    super.key,
    required this.avatarUrl,
    required this.nome,
    required this.verificado,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iniciais = nome.trim().isNotEmpty
        ? nome.trim()[0].toUpperCase()
        : '?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? Text(
                  iniciais,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        if (verificado)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
