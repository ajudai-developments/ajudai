import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_text_styles.dart';
import 'acoes_agendamento_row.dart';
import 'agendamento_com_detalhes.dart';
import 'status_badge.dart';

enum _GrupoStatus { ativo, concluido, encerrado }

_GrupoStatus _grupoDe(StatusAgendamento status) {
  switch (status) {
    case StatusAgendamento.pendente:
    case StatusAgendamento.aceito:
    case StatusAgendamento.emAndamento:
    case StatusAgendamento.aguardandoConfirmacao:
      return _GrupoStatus.ativo;
    case StatusAgendamento.concluido:
      return _GrupoStatus.concluido;
    case StatusAgendamento.recusado:
    case StatusAgendamento.cancelado:
    case StatusAgendamento.naoConcluido:
    case StatusAgendamento.contestado:
      return _GrupoStatus.encerrado;
  }
}

/// Card compacto de um agendamento.
///
/// Reutilizado em: meus_agendamentos_screen e
/// agendamentos_recebidos_screen (aba "Ativos" e aba "Histórico"), pros
/// dois papéis (cliente/prestador).
///
/// Propositalmente enxuto — só o que ajuda a reconhecer o agendamento
/// numa lista (serviço, contraparte, data, valor, endereço resumido).
/// Detalhes completos (linha do tempo, endereço completo, contestação
/// etc.) ficam só na tela de detalhe, pra caber vários cards na tela
/// sem precisar rolar demais.
class AgendamentoCard extends StatelessWidget {
  final AgendamentoComDetalhes item;
  final VoidCallback onTap;
  final ExecutarAcaoDoItem onExecutarAcao;
  final VoidCallback onAvaliar;

  const AgendamentoCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onExecutarAcao,
    required this.onAvaliar,
  });

  String _dois(int n) => n.toString().padLeft(2, '0');

  String _data(DateTime utc) {
    final l = utc.toLocal();
    return '${_dois(l.day)}/${_dois(l.month)}';
  }

  String _hora(DateTime utc) {
    final l = utc.toLocal();
    return '${_dois(l.hour)}:${_dois(l.minute)}';
  }

  String _periodo() {
    final inicio = item.agendamento.horaInicio.toLocal();
    final fim = item.agendamento.horaFim.toLocal();
    final mesmoDia =
        inicio.year == fim.year &&
        inicio.month == fim.month &&
        inicio.day == fim.day;

    if (mesmoDia) {
      return '${_data(inicio)} · ${_hora(inicio)}–${_hora(fim)}';
    }
    return '${_data(inicio)} ${_hora(inicio)} → ${_data(fim)} ${_hora(fim)}';
  }

  String _enderecoResumo() {
    final a = item.agendamento;
    return '${a.enderecoBairro}, ${a.enderecoCidade}/${a.enderecoEstado}';
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }

  Color _corDestaque(ColorScheme scheme) {
    switch (_grupoDe(item.agendamento.status)) {
      case _GrupoStatus.ativo:
        return scheme.primary;
      case _GrupoStatus.concluido:
        return Colors.green.shade600;
      case _GrupoStatus.encerrado:
        return scheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final a = item.agendamento;
    final corDestaque = _corDestaque(scheme);
    final avatarUrl = item.contraparteAvatarUrl;
    final temAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final rotulo = item.comoCliente ? 'Prestador' : 'Cliente';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: corDestaque),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: scheme.primaryContainer,
                              backgroundImage: temAvatar
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: temAvatar
                                  ? null
                                  : Text(
                                      _iniciais(item.nomeContraparte),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: scheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nomeServico,
                                    style: AppTextStyles.corpo.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  Row(
                                    children: [
                                      Text(
                                        '$rotulo · ',
                                        style: AppTextStyles.legenda,
                                      ),
                                      Flexible(
                                        child: Text(
                                          item.nomeContraparte,
                                          style: AppTextStyles.legenda.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (item.contraparteVerificada) ...[
                                        const SizedBox(width: 3),
                                        Icon(
                                          Icons.verified_rounded,
                                          size: 12,
                                          color: scheme.primary,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(status: a.status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.event_rounded,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _periodo(),
                                style: AppTextStyles.legenda,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'R\$ ${a.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: AppTextStyles.corpo.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _enderecoResumo(),
                                style: AppTextStyles.legenda,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                        AcoesAgendamentoRow(
                          item: item,
                          onExecutarAcao: onExecutarAcao,
                          onAvaliar: onAvaliar,
                          denso: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
