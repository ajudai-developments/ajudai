import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class EnderecoCard extends StatelessWidget {
  final Endereco endereco;
  final VoidCallback onEditar;

  const EnderecoCard({super.key, required this.endereco, required this.onEditar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.fundoCampo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.vermelho),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(endereco.nome, style: AppTextStyles.corpo.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${endereco.logradouro}, ${endereco.numero}'
                  '${endereco.complemento != null ? ' - ${endereco.complemento}' : ''}\n'
                  '${endereco.bairro} - ${endereco.cidade}/${endereco.estado}',
                  style: AppTextStyles.secundario,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.cinzaEscuro),
            onPressed: onEditar,
          ),
        ],
      ),
    );
  }
}