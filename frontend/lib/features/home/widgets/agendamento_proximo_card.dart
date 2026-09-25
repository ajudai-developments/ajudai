import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_text_styles.dart';

/// Card compacto de um agendamento "próximo" (cliente ou prestador),
/// usado na Home. Não sabe a diferença entre papéis — só recebe os
/// dados já resolvidos (nome da outra pessoa, avatar, etc).
class AgendamentoProximoCard extends StatelessWidget {
  final String nome;
  final String? avatarUrl;
  final bool verificado;
  final Agendamento agendamento;
  final String subtitulo;

  const AgendamentoProximoCard({
    super.key,
    required this.nome,
    required this.avatarUrl,
    required this.verificado,
    required this.agendamento,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    final status = _StatusInfo.de(agendamento.status.valor);
    final corDestaque = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nome,
                            style: AppTextStyles.corpo.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (verificado) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified, size: 16, color: corDestaque),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: AppTextStyles.corpo.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                _formatarDataHora(agendamento.horaInicio),
                style: AppTextStyles.corpo.copyWith(fontSize: 13),
              ),
              const Spacer(),
              Text(
                _formatarValor(agendamento.valor),
                style: AppTextStyles.corpo.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final _StatusInfo status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: status.cor,
        ),
      ),
    );
  }
}

class _StatusInfo {
  final String label;
  final Color cor;
  const _StatusInfo(this.label, this.cor);

  /// Baseado no valor "de fio" (string) do status, pra não depender dos
  /// nomes exatos dos membros do enum StatusAgendamento.
  static _StatusInfo de(String valor) {
    switch (valor) {
      case 'pendente':
        return const _StatusInfo('Pendente', Colors.orange);
      case 'aceito':
        return const _StatusInfo('Aceito', Colors.blue);
      case 'em_andamento':
        return const _StatusInfo('Em andamento', Colors.green);
      case 'aguardando_confirmacao':
        return const _StatusInfo('Aguardando confirmação', Colors.amber);
      case 'concluido':
        return const _StatusInfo('Concluído', Colors.grey);
      case 'recusado':
        return const _StatusInfo('Recusado', Colors.red);
      case 'cancelado':
        return const _StatusInfo('Cancelado', Colors.red);
      case 'nao_concluido':
        return const _StatusInfo('Não concluído', Colors.redAccent);
      case 'contestado':
        return const _StatusInfo('Contestado', Colors.deepOrange);
      default:
        return _StatusInfo(valor, Colors.grey);
    }
  }
}

String _formatarDataHora(DateTime dt) {
  final local = dt.toLocal();
  final agora = DateTime.now();
  final data = DateTime(local.year, local.month, local.day);
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final amanha = hoje.add(const Duration(days: 1));

  final hora =
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';

  if (data == hoje) return 'Hoje, $hora';
  if (data == amanha) return 'Amanhã, $hora';

  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  return '$dia/$mes, $hora';
}

String _formatarValor(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}
