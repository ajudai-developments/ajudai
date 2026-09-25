import 'package:ajudai/features/agendamento/widgets/acoes_agendamento_row.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_text_styles.dart';
import 'agendamento_com_detalhes.dart';

/// Card de destaque pro agendamento mais próximo de ocorrer (ou já em
/// andamento). Fica sempre no topo da listagem, acima dos filtros — é
/// o "o que importa agora" da tela. Visual mais discreto que um banner
/// colorido cheio: usa a cor de destaque só em detalhes pontuais.
class AgendamentoDestaqueCard extends StatelessWidget {
  final AgendamentoComDetalhes item;
  final VoidCallback onTap;
  final ExecutarAcaoDoItem onExecutarAcao; // novo
  final VoidCallback onAvaliar; // novo

  const AgendamentoDestaqueCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onExecutarAcao,
    required this.onAvaliar,
  });

  String _dois(int n) => n.toString().padLeft(2, '0');

  bool get _emAndamento =>
      item.agendamento.status == StatusAgendamento.emAndamento;

  String _rotuloTempo() {
    final a = item.agendamento;
    if (_emAndamento) return 'Em andamento agora';

    final inicio = a.horaInicio.toLocal();
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dia = DateTime(inicio.year, inicio.month, inicio.day);
    final hora = '${_dois(inicio.hour)}:${_dois(inicio.minute)}';

    if (dia == hoje) return 'Hoje às $hora';
    if (dia == hoje.add(const Duration(days: 1))) return 'Amanhã às $hora';

    return '${_dois(inicio.day)}/${_dois(inicio.month)} às $hora';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rotulo = item.comoCliente ? 'Prestador' : 'Cliente';
    final avatarUrl = item.contraparteAvatarUrl;
    final temAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final corDestaque = _emAndamento ? Colors.green.shade600 : scheme.primary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                // Barra lateral fina com a cor de destaque.
                Container(width: 4, color: corDestaque),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _emAndamento
                                  ? Icons.play_circle_fill_rounded
                                  : Icons.schedule_rounded,
                              size: 15,
                              color: corDestaque,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _emAndamento
                                  ? 'EM ANDAMENTO'
                                  : 'PRÓXIMO AGENDAMENTO',
                              style: TextStyle(
                                color: corDestaque,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.nomeServico,
                          style: AppTextStyles.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _rotuloTempo(),
                          style: AppTextStyles.corpo.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: scheme.surfaceContainerHighest,
                              backgroundImage: temAvatar
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: temAvatar
                                  ? null
                                  : Icon(
                                      Icons.person,
                                      size: 16,
                                      color: scheme.onSurfaceVariant,
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(rotulo, style: AppTextStyles.legenda),
                                  Text(
                                    item.nomeContraparte,
                                    style: AppTextStyles.corpo.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                        AcoesAgendamentoRow(
                          item: item,
                          onExecutarAcao: onExecutarAcao,
                          onAvaliar: onAvaliar,
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
