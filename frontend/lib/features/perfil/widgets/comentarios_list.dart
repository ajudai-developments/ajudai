import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_text_styles.dart';

/// Lista de comentários (AvaliacaoUsuario) — nome de quem avaliou, nota
/// e mensagem opcional.
///
/// Reutilizado em servico_detalhe_screen e perfil_publico_screen.
///
/// Não usa RatingDisplay (core/widgets) pra nota individual — aquele
/// widget foi desenhado pra média+contagem, não pra uma nota isolada de
/// um comentário.
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
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(comentario.avaliadorNome, style: AppTextStyles.corpo),
                        ),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(comentario.avaliacao.toStringAsFixed(1)),
                      ],
                    ),
                    if (comentario.mensagem != null) ...[
                      const SizedBox(height: 4),
                      Text(comentario.mensagem!, style: AppTextStyles.corpo),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}