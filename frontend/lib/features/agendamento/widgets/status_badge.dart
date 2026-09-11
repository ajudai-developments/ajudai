import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';

/// Badge visual do status de um agendamento.
///
/// Mapeamento de cor por status ainda não foi validado com design —
/// usei o que já existe na paleta (primary = ação/negativo, success =
/// concluído, warning = precisa de atenção, textoSecundario = neutro em
/// andamento) de um jeito que faça sentido semanticamente. Ajustar
/// quando houver convenção oficial de cores de status.
class StatusBadge extends StatelessWidget {
  final StatusAgendamento status;

  const StatusBadge({super.key, required this.status});

  String get _texto {
    switch (status) {
      case StatusAgendamento.pendente:
        return 'Aguardando resposta';
      case StatusAgendamento.aceito:
        return 'Aceito';
      case StatusAgendamento.emAndamento:
        return 'Em andamento';
      case StatusAgendamento.recusado:
        return 'Recusado';
      case StatusAgendamento.cancelado:
        return 'Cancelado';
      case StatusAgendamento.aguardandoConfirmacao:
        return 'Aguardando confirmação';
      case StatusAgendamento.concluido:
        return 'Concluído';
      case StatusAgendamento.naoConcluido:
        return 'Não concluído';
      case StatusAgendamento.contestado:
        return 'Contestado';
    }
  }

  Color get _cor {
    switch (status) {
      case StatusAgendamento.concluido:
        return AppColors.success;
      case StatusAgendamento.recusado:
      case StatusAgendamento.cancelado:
      case StatusAgendamento.naoConcluido:
      case StatusAgendamento.contestado:
        return AppColors.primary;
      case StatusAgendamento.pendente:
      case StatusAgendamento.aguardandoConfirmacao:
        return AppColors.warning;
      case StatusAgendamento.aceito:
      case StatusAgendamento.emAndamento:
        return AppColors.textoSecundario;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _texto,
        style: TextStyle(color: _cor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}