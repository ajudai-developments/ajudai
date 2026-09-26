import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Linha do tempo com tudo que aconteceu no agendamento — combina
/// mudanças de status/preço/horário/endereço (`historico_agendamentos`)
/// e eventos automáticos do sistema (alertas, confirmação automática).
class TimelineAgendamentoView extends StatelessWidget {
  final List<TimelineItemAgendamento> itens;

  const TimelineAgendamentoView({super.key, required this.itens});

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < itens.length; i++)
          _TimelineTile(item: itens[i], ultimo: i == itens.length - 1),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final TimelineItemAgendamento item;
  final bool ultimo;

  const _TimelineTile({required this.item, required this.ultimo});

  IconData get _icone {
    switch (item.tipo) {
      case 'criado':
        return Icons.add_circle_outline;
      case 'status':
        return Icons.sync_alt;
      case 'preco':
        return Icons.attach_money;
      case 'horario':
        return Icons.schedule;
      case 'endereco':
        return Icons.location_on_outlined;
      case 'alerta_inicio':
      case 'alerta_finalizacao':
      case 'alerta_atraso':
        return Icons.notifications_active_outlined;
      case 'confirmacao_automatica':
        return Icons.verified_outlined;
      case 'cancelado_por_atraso':
        return Icons.cancel_outlined;
      case 'denuncia_atraso':
        return Icons.report_gmailerrorred_outlined;
      case 'nao_concluido':
        return Icons.error_outline;
      default:
        return Icons.circle;
    }
  }

  String get _titulo {
    switch (item.tipo) {
      case 'criado':
        return 'Agendamento criado';
      case 'status':
        return 'Status alterado para "${_statusLabel(item.status)}"';
      case 'preco':
        return 'Preço alterado';
      case 'horario':
        return 'Horário alterado';
      case 'endereco':
        return 'Endereço alterado';
      case 'alerta_inicio':
        return 'Alerta de início enviado';
      case 'alerta_finalizacao':
        return 'Alerta de finalização enviado';
      case 'alerta_atraso':
        return 'Alerta de atraso enviado';
      case 'confirmacao_automatica':
        return 'Confirmado automaticamente';
      case 'cancelado_por_atraso':
        return 'Cancelado por atraso';
      case 'denuncia_atraso':
        return 'Denúncia de atraso registrada';
      case 'nao_concluido':
        return 'Marcado como não concluído';
      default:
        return item.tipo;
    }
  }

  String _statusLabel(String? valor) {
    if (valor == null) return '';
    late final StatusAgendamento status;
    try {
      status = StatusAgendamento.fromValor(valor);
    } catch (_) {
      return valor;
    }
    return switch (status) {
      StatusAgendamento.pendente => 'Pendente',
      StatusAgendamento.aceito => 'Aceito',
      StatusAgendamento.recusado => 'Recusado',
      StatusAgendamento.emAndamento => 'Em andamento',
      StatusAgendamento.aguardandoConfirmacao => 'Aguardando confirmação',
      StatusAgendamento.concluido => 'Concluído',
      StatusAgendamento.cancelado => 'Cancelado',
      StatusAgendamento.contestado => 'Contestado',
      StatusAgendamento.naoConcluido => 'Não concluído',
    };
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icone, size: 16, color: cor),
              ),
              if (!ultimo)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: ultimo ? 0 : 20, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titulo,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatarDataHora(item.ocorridoEm),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (item.alteradoPorNome != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Por ${item.alteradoPorNome}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatarDataHora(DateTime dt) {
  final local = dt.toLocal();
  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  final hora = local.hour.toString().padLeft(2, '0');
  final min = local.minute.toString().padLeft(2, '0');
  return '$dia/$mes/${local.year}, $hora:$min';
}
