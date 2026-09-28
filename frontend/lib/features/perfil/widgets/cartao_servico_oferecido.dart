import 'package:ajudai/features/servico/widgets/servico_icones.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CartaoServicoOferecido extends StatelessWidget {
  final ServicoOferecidoResumo servico;
  final VoidCallback onTap;

  const CartaoServicoOferecido({
    required this.servico,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconeDoServico(servico.servicoNome),
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servico.servicoNome,
                    style: AppTextStyles.corpo.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textoTitulo,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(servico.categoriaNome, style: AppTextStyles.legenda),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${servico.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: AppTextStyles.preco.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textoSecundario,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
