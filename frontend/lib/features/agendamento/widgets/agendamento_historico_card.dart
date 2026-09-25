import 'package:ajudai/features/agendamento/widgets/avaliacao_elegibilidade.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_text_styles.dart';
import 'agendamento_com_detalhes.dart';
import 'status_badge.dart';

enum _GrupoStatusHistorico { concluido, encerrado }

_GrupoStatusHistorico _grupoDe(StatusAgendamento status) =>
    status == StatusAgendamento.concluido
    ? _GrupoStatusHistorico.concluido
    : _GrupoStatusHistorico.encerrado;

/// Card compacto pra itens do HISTÓRICO (concluído/cancelado).
///
/// Diferente do AgendamentoCard (usado nos ativos): aqui não existem
/// ações de ciclo de vida (aceitar/iniciar/cancelar...). Só cabem:
/// "Avaliar" (só quando concluído e dentro de 24h da conclusão) e o
/// menu de mais opções (denunciar a contraparte / contestar o
/// agendamento), sempre disponíveis em qualquer item do histórico.
class AgendamentoHistoricoCard extends StatelessWidget {
  final AgendamentoComDetalhes item;
  final VoidCallback onTap;
  final void Function(AgendamentoComDetalhes item) onAvaliar;
  final void Function(AgendamentoComDetalhes item) onDenunciar;
  final void Function(AgendamentoComDetalhes item) onContestar;

  const AgendamentoHistoricoCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAvaliar,
    required this.onDenunciar,
    required this.onContestar,
  });

  String _dois(int n) => n.toString().padLeft(2, '0');

  String _data(DateTime utc) {
    final l = utc.toLocal();
    return '${_dois(l.day)}/${_dois(l.month)}/${l.year}';
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }

  Color _corDestaque(ColorScheme scheme) {
    switch (_grupoDe(item.agendamento.status)) {
      case _GrupoStatusHistorico.concluido:
        return Colors.green.shade600;
      case _GrupoStatusHistorico.encerrado:
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
    final elegibilidade = AvaliacaoElegibilidade.calcular(item);

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
                    padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
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
                                  Text(
                                    '$rotulo · ${item.nomeContraparte}',
                                    style: AppTextStyles.legenda,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(status: a.status),
                            _buildMenu(context),
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
                            Text(
                              _data(a.horaInicio),
                              style: AppTextStyles.legenda,
                            ),
                            const Spacer(),
                            Text(
                              'R\$ ${a.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: AppTextStyles.corpo.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (elegibilidade.podeAvaliar) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () => onAvaliar(item),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: scheme.primary,
                                minimumSize: const Size(0, 32),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: const Icon(
                                Icons.star_border_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'Avaliar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onSelected: (v) {
        if (v == 'denunciar') onDenunciar(item);
        if (v == 'contestar') onContestar(item);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'contestar',
          child: Row(
            children: [
              Icon(Icons.report_problem_outlined, size: 18),
              SizedBox(width: 8),
              Text('Contestar agendamento'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'denunciar',
          child: Row(
            children: [
              const Icon(Icons.flag_outlined, size: 18),
              const SizedBox(width: 8),
              Text('Denunciar ${item.comoCliente ? 'prestador' : 'cliente'}'),
            ],
          ),
        ),
      ],
    );
  }
}
