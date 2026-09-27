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

  /// Cor do texto e, se [corEstrela] não for informada, também do ícone.
  /// Passar explicitamente (em vez de confiar em Theme/DefaultTextStyle
  /// herdado) é o que garante contraste correto quando este widget é
  /// usado sobre um fundo colorido (ex: cabeçalho vermelho do perfil) —
  /// um Theme() ancestral não repinta um Text sem estilo próprio, porque
  /// o DefaultTextStyle já foi fixado mais acima pelo Material do Scaffold.
  final Color? cor;

  /// Cor do ícone de estrela. Se omitida, usa [cor] quando informada,
  /// senão o dourado padrão (Colors.amber).
  final Color? corEstrela;

  const RatingDisplay({
    super.key,
    required this.media,
    required this.quantidadeAvaliacoes,
    this.tamanho = 16,
    this.cor,
    this.corEstrela,
  });

  @override
  Widget build(BuildContext context) {
    final estiloTexto = cor != null ? TextStyle(color: cor) : null;

    if (media == null || quantidadeAvaliacoes == 0) {
      return Text('Sem avaliações ainda', style: estiloTexto);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: tamanho,
          color: corEstrela ?? cor ?? Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          '${media!.toStringAsFixed(1)} ($quantidadeAvaliacoes)',
          style: estiloTexto,
        ),
      ],
    );
  }
}
