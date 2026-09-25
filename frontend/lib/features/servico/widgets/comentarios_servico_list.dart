import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_text_styles.dart';

/// Lista de comentários (AvaliacaoServico) — nome de quem avaliou, nota
/// e mensagem opcional, feitos sobre um serviço/agendamento específico.
///
/// Mesmo visual de [ComentariosList] (que trabalha com AvaliacaoUsuario,
/// avaliação da pessoa em geral) — mantidos como widgets separados
/// porque os models são diferentes e cada um é usado num contexto.
///
/// Usado em servico_detalhe_screen.
class ComentariosServicoList extends StatelessWidget {
  final List<AvaliacaoServico> comentarios;

  const ComentariosServicoList({super.key, required this.comentarios});

  @override
  Widget build(BuildContext context) {
    if (comentarios.isEmpty) {
      return Text(
        'Ainda não há comentários.',
        style: AppTextStyles.corpo.copyWith(color: Colors.black45),
      );
    }

    return Column(
      children: [
        for (final comentario in comentarios)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEDEDED)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comentario.avaliadorNome,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            comentario.avaliacao.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (comentario.mensagem != null &&
                    comentario.mensagem!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    comentario.mensagem!,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
