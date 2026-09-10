import 'package:flutter/material.dart';

/// Exibição SOMENTE LEITURA de uma média de avaliação (estrelas).
///
/// Reutilizado em: servico_card, servico_detalhe_screen, perfil_publico_screen
/// (tanto para a média dos serviços oferecidos quanto para a avaliação
/// pessoal do usuário/prestador).
///
/// Para o INPUT interativo de avaliação (dar nota após concluir um
/// agendamento), ver features/avaliacao/widgets/rating_input.dart.
class RatingDisplay extends StatelessWidget {
  final double? media;
  final int quantidadeAvaliacoes;
  final double tamanho;

  const RatingDisplay({
    super.key,
    required this.media,
    required this.quantidadeAvaliacoes,
    this.tamanho = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (media == null || quantidadeAvaliacoes == 0) {
      return const Text('Sem avaliações ainda');
    }
    // TODO: renderizar estrelas (cheias/meias/vazias) com base em `media`.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: tamanho, color: Colors.amber),
        const SizedBox(width: 4),
        Text('${media!.toStringAsFixed(1)} ($quantidadeAvaliacoes)'),
      ],
    );
  }
}