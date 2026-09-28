import 'package:flutter/material.dart';

/// Distribui [children] em colunas conforme a largura disponível.
/// Cada card ocupa no mínimo [larguraMinItem]; o número de colunas
/// sobe até [maxColunas]. Os itens de uma mesma linha ficam com a
/// mesma altura, então não precisa saber a altura do card.
class GradeAdaptativa extends StatelessWidget {
  final List<Widget> children;
  final double larguraMinItem;
  final int maxColunas;
  final double espaco;

  const GradeAdaptativa({
    super.key,
    required this.children,
    this.larguraMinItem = 340,
    this.maxColunas = 3,
    this.espaco = 20,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final colunas = ((c.maxWidth + espaco) / (larguraMinItem + espaco))
            .floor()
            .clamp(1, maxColunas);

        final linhas = <Widget>[];
        for (var i = 0; i < children.length; i += colunas) {
          final fim = (i + colunas).clamp(0, children.length);
          final grupo = children.sublist(i, fim);

          linhas.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < colunas; j++) ...[
                    if (j > 0) SizedBox(width: espaco),
                    Expanded(
                      child: j < grupo.length ? grupo[j] : const SizedBox(),
                    ),
                  ],
                ],
              ),
            ),
          );
          if (fim < children.length) linhas.add(SizedBox(height: espaco));
        }

        return Column(children: linhas);
      },
    );
  }
}
