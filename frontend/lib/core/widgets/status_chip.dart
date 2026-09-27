import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Badge de status usado em contestações e denúncias — os dois enums
/// compartilham os mesmos valores textuais, então um widget só cobre
/// ambos os casos.
class StatusChip extends StatelessWidget {
  final String valor;
  const StatusChip({super.key, required this.valor});

  Color get _cor {
    switch (valor) {
      case 'aberta':
        return AppColors.warning;
      case 'em_analise':
        return AppColors.primary;
      case 'resolvida':
        return AppColors.success;
      case 'rejeitada':
        return AppColors.error;
      default:
        return AppColors.textoSecundario;
    }
  }

  String get _label {
    switch (valor) {
      case 'aberta':
        return 'Aberta';
      case 'em_analise':
        return 'Em análise';
      case 'resolvida':
        return 'Resolvida';
      case 'rejeitada':
        return 'Rejeitada';
      default:
        return valor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = _cor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label,
        style: AppTextStyles.label.copyWith(color: cor, fontSize: 11),
      ),
    );
  }
}
