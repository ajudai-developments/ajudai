// lib/src/features/agendamento/presentation/widgets/resumo_servico.dart
import 'package:ajudai/src/core/theme/app_colors.dart';
import 'package:ajudai/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ResumoServico extends StatelessWidget {
  final ServicoOferecidoPreview servicoOferecido;

  const ResumoServico({
    super.key,
    required this.servicoOferecido,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoCampo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.vermelho.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  color: AppColors.vermelho,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servicoOferecido.servicoNome,
                      style: AppTextStyles.corpo.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      servicoOferecido.prestadorNome,
                      style: AppTextStyles.subtitulo,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${servicoOferecido.valor.toStringAsFixed(2)}',
                    style: AppTextStyles.titulo.copyWith(
                      fontSize: 18,
                      color: AppColors.vermelho,
                    ),
                  ),
                  if (servicoOferecido.prestadorVerificado)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.verde.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.verde,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verificado',
                            style: AppTextStyles.secundario.copyWith(
                              color: AppColors.verde,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (servicoOferecido.mediaAvaliacao != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  final value = servicoOferecido.mediaAvaliacao!;
                  if (index < value.floor()) {
                    return const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    );
                  } else if (index == value.floor() && value % 1 >= 0.5) {
                    return const Icon(
                      Icons.star_half_rounded,
                      color: Colors.amber,
                      size: 16,
                    );
                  } else {
                    return const Icon(
                      Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 16,
                    );
                  }
                }),
                const SizedBox(width: 8),
                Text(
                  '${servicoOferecido.quantidadeAvaliacoes} avaliações',
                  style: AppTextStyles.secundario.copyWith(fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}