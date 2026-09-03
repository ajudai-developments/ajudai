// lib/src/features/agendamento/presentation/widgets/prestador_card.dart
import 'package:ajudai/src/core/theme/app_colors.dart';
import 'package:ajudai/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class PrestadorCard extends StatelessWidget {
  final ServicoOferecidoPreview servicoOferecido;
  final VoidCallback onTap;

  const PrestadorCard({
    super.key,
    required this.servicoOferecido,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.vermelho.withValues(alpha: 0.1),
                    child: Text(
                      servicoOferecido.prestadorNome[0].toUpperCase(),
                      style: AppTextStyles.titulo.copyWith(
                        fontSize: 18,
                        color: AppColors.vermelho,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                servicoOferecido.prestadorNome,
                                style: AppTextStyles.corpo.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (servicoOferecido.prestadorVerificado)
                              Icon(
                                Icons.verified_rounded,
                                color: AppColors.verde,
                                size: 18,
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              if (servicoOferecido.mediaAvaliacao != null &&
                                  index < servicoOferecido.mediaAvaliacao!) {
                                return const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 14,
                                );
                              } else {
                                return const Icon(
                                  Icons.star_border_rounded,
                                  color: Colors.amber,
                                  size: 14,
                                );
                              }
                            }),
                            const SizedBox(width: 4),
                            Text(
                              '(${servicoOferecido.quantidadeAvaliacoes})',
                              style: AppTextStyles.secundario.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'R\$ ${servicoOferecido.valor.toStringAsFixed(2)}',
                        style: AppTextStyles.titulo.copyWith(
                          fontSize: 18,
                          color: AppColors.vermelho,
                        ),
                      ),
                      if (servicoOferecido.quantidadeSelos > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${servicoOferecido.quantidadeSelos} selos',
                              style: AppTextStyles.secundario.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.vermelho,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Agendar',
                      style: AppTextStyles.corpo.copyWith(
                        color: AppColors.branco,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
