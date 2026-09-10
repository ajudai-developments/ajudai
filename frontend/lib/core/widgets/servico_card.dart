import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'rating_display.dart';

/// Card resumido de um serviço oferecido.
///
/// Reutilizado em: servicos_lista_screen (busca/listagem) e
/// perfil_publico_screen (serviços oferecidos por um prestador).
///
/// O botão "Agendar" leva direto para a tela de criação de agendamento
/// referente a este servico_oferecido_id.
class ServicoCard extends StatelessWidget {
  final ServicoOferecidoPreview servico;
  final VoidCallback onTapDetalhe;
  final VoidCallback onTapAgendar;

  const ServicoCard({
    super.key,
    required this.servico,
    required this.onTapDetalhe,
    required this.onTapAgendar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTapDetalhe,
        title: Text(servico.servicoNome),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(servico.prestadorNome),
            RatingDisplay(
              media: servico.mediaAvaliacao,
              quantidadeAvaliacoes: servico.quantidadeAvaliacoes,
            ),
          ],
        ),
        trailing: TextButton(
          onPressed: onTapAgendar,
          child: const Text('Agendar'),
        ),
      ),
    );
  }
}