import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_text_styles.dart';

/// Selos (conquistas) do usuário exibidos em destaque, logo abaixo da
/// foto de perfil — diferente de [SelosList] (chips com texto, usados
/// dentro do corpo do perfil público/detalhe de serviço), este widget é
/// pensado pra ficar centralizado no topo da tela, junto do avatar.
///
/// Não renderiza nada se a lista estiver vazia (usuário ainda sem
/// nenhuma conquista) — quem chama nem precisa checar `isEmpty` antes.
class SelosDestaque extends StatelessWidget {
  final List<ConquistaUsuario> selos;

  const SelosDestaque({super.key, required this.selos});

  @override
  Widget build(BuildContext context) {
    if (selos.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [for (final selo in selos) _buildSelo(selo)],
    );
  }

  Widget _buildSelo(ConquistaUsuario selo) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 18,
            child: Icon(Icons.emoji_events, size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            selo.conquista.nome,
            style: AppTextStyles.legenda,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
