// lib/src/features/servicos/presentation/widgets/servico_card.dart
import 'package:ajudai/src/core/theme/app_colors.dart';
import 'package:ajudai/src/core/theme/app_text_styles.dart';
import 'package:ajudai/src/features/agendamento/presentation/prestadores_page.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ServicoCard extends StatelessWidget {
  final ServicoOferecidoPreview servico;
  final VoidCallback? onTap;

  const ServicoCard({super.key, required this.servico, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          // Navegar para lista de prestadores do serviço
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrestadoresPage(
                servico: Servico(
                  id: servico.servicoOferecidoId,
                  nome: servico.servicoNome,
                  categoriaId: servico.servicoOferecidoId,
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.vermelho.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  color: AppColors.vermelho,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servico.servicoNome,
                      style: AppTextStyles.corpo.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Clique para ver prestadores',
                      style: AppTextStyles.secundario.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.cinzaClaro,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
