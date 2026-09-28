import 'package:ajudai/core/layout/responsivo.dart';
import 'package:flutter/material.dart';

class CamposEmLinha extends StatelessWidget {
  final List<Widget> filhos;
  final double espaco;

  const CamposEmLinha({super.key, required this.filhos, this.espaco = 12});

  @override
  Widget build(BuildContext context) {
    if (!context.usaLayoutWeb) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < filhos.length; i++) ...[
            if (i > 0) SizedBox(height: espaco),
            filhos[i],
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < filhos.length; i++) ...[
          if (i > 0) SizedBox(width: espaco),
          Expanded(child: filhos[i]),
        ],
      ],
    );
  }
}
