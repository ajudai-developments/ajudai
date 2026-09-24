import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class FalhaNoAnexo extends StatelessWidget {
  final String? nome;

  const FalhaNoAnexo({this.nome, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.attach_file, color: AppColors.primary),
        const SizedBox(width: 6),
        Flexible(child: Text(nome ?? 'Anexo indisponível')),
      ],
    );
  }
}
