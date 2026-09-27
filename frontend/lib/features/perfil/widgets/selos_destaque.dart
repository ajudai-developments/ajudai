import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
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

  /// Quando `true` (uso sobre fundo vermelho, ex: cabeçalho do perfil),
  /// o texto e o círculo do selo trocam pra tons claros/brancos em vez
  /// da cor padrão — senão ficam ilegíveis sobre o vermelho.
  final bool sobreFundoEscuro;

  const SelosDestaque({
    super.key,
    required this.selos,
    this.sobreFundoEscuro = false,
  });

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
    final corFundo = sobreFundoEscuro
        ? Colors.white.withValues(alpha: 0.18)
        : AppColors.avaliacao.withValues(alpha: 0.14);
    final corIcone = sobreFundoEscuro ? Colors.white : AppColors.avaliacao;
    final corTexto = sobreFundoEscuro
        ? Colors.white.withValues(alpha: 0.9)
        : AppColors.textoNormal;

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: corFundo,
            child: Icon(Icons.emoji_events_rounded, size: 20, color: corIcone),
          ),
          const SizedBox(height: 6),
          Text(
            selo.conquista.nome,
            style: AppTextStyles.legenda.copyWith(color: corTexto),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
