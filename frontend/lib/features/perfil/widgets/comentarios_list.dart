import 'package:ajudai/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Lista de comentários (AvaliacaoUsuario) — nome de quem avaliou, nota
/// e mensagem opcional.
///
/// Reutilizado em servico_detalhe_screen e perfil_publico_screen.
class ComentariosList extends StatelessWidget {
  final List<AvaliacaoUsuario> comentarios;

  const ComentariosList({super.key, required this.comentarios});

  @override
  Widget build(BuildContext context) {
    if (comentarios.isEmpty) {
      return Text('Ainda não há comentários.', style: AppTextStyles.corpo);
    }

    return Column(
      children: [
        for (final comentario in comentarios)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          UserAvatar(
                            avatarUrl: comentario.avaliadorAvatarUrl,
                            radius: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              comentario.avaliadorNome,
                              style: AppTextStyles.corpo.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textoTitulo,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.avaliacao.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.avaliacao,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            comentario.avaliacao.toStringAsFixed(1),
                            style: AppTextStyles.label,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (comentario.mensagem != null &&
                    comentario.mensagem!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(comentario.mensagem!, style: AppTextStyles.corpo),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
