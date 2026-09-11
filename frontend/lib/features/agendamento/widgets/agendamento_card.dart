import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../agendamento_com_detalhes.dart';
import 'status_badge.dart';

/// Card resumido de um agendamento.
///
/// Reutilizado em: meus_agendamentos_screen e
/// agendamentos_recebidos_screen (o mesmo card serve pros dois lados,
/// cliente e prestador — nenhuma das duas listas precisa de layout
/// diferente por enquanto).
class AgendamentoCard extends StatelessWidget {
  final AgendamentoComDetalhes item;
  final VoidCallback onTap;

  const AgendamentoCard({super.key, required this.item, required this.onTap});

  String _formatarData(DateTime utc) {
    final local = utc.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return '$dia/$mes às $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    final agendamento = item.agendamento;

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(item.nomeServico, style: AppTextStyles.titulo),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.nomePrestador != null ? 'com ${item.nomePrestador}' : 'Cliente',
              style: AppTextStyles.corpo,
            ),
            Text(_formatarData(agendamento.horaInicio), style: AppTextStyles.legenda),
            Text(
              '${agendamento.enderecoLogradouro}, ${agendamento.enderecoNumero}',
              style: AppTextStyles.legenda,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('R\$ ${agendamento.valor.toStringAsFixed(2)}', style: AppTextStyles.corpo),
            const SizedBox(height: 4),
            StatusBadge(status: agendamento.status),
          ],
        ),
      ),
    );
  }
}