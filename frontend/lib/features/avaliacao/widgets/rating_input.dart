import 'package:flutter/material.dart';

/// Input interativo de avaliação (1 a 5 estrelas inteiras).
///
/// Diferente de RatingDisplay (core/widgets), que só EXIBE uma média
/// somada com contagem — aqui o usuário toca pra escolher uma nota.
/// Usado em avaliar_agendamento_screen e avaliar_usuario_screen.
///
/// Nota: a coluna `avaliacao` no banco é double (aceita 0–5 com casas
/// decimais), mas a UI só oferece estrelas inteiras (1 a 5) por
/// simplicidade — meia estrela pediria um gesto mais elaborado
/// (arrastar) que não implementei aqui.
class RatingInput extends StatelessWidget {
  final int valor; // 0 = nada selecionado ainda
  final ValueChanged<int> onChanged;

  const RatingInput({super.key, required this.valor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            iconSize: 36,
            onPressed: () => onChanged(i),
            icon: Icon(
              i <= valor ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
          ),
      ],
    );
  }
}