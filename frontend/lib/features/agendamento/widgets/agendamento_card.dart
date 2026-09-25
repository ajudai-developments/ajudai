import 'package:ajudai/core/routes/app_routes.dart';
import 'package:ajudai/features/agendamento/widgets/acoes_agendamento_row.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_text_styles.dart';
import 'agendamento_com_detalhes.dart';
import 'status_badge.dart';

/// Grupo semântico de um status, só pra escolher a cor de destaque do
/// card (a mesma lógica de agrupamento usada nos filtros da listagem).
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

/// Card de um agendamento.
///
/// Reutilizado em: meus_agendamentos_screen e
/// agendamentos_recebidos_screen (o mesmo card serve pros dois lados,
/// cliente e prestador). O rótulo da contraparte muda conforme o papel:
/// quem vê como cliente enxerga o "Prestador", e vice-versa.
class AgendamentoCard extends StatelessWidget {
  final AgendamentoComDetalhes item;
  final VoidCallback onTap;
  final ExecutarAcaoDoItem onExecutarAcao; // novo
  final VoidCallback onAvaliar; // novo

  const AgendamentoCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onExecutarAcao,
    required this.onAvaliar,
  });

  // ---------------------------------------------------------------
  // Formatação
  // ---------------------------------------------------------------

  String _dois(int n) => n.toString().padLeft(2, '0');

  String _data(DateTime utc) {
    final l = utc.toLocal();
    return '${_dois(l.day)}/${_dois(l.month)}/${l.year}';
  }

  String _hora(DateTime utc) {
    final l = utc.toLocal();
    return '${_dois(l.hour)}:${_dois(l.minute)}';
  }

  String _dataHora(DateTime utc) => '${_data(utc)} às ${_hora(utc)}';

  String _periodo() {
    final inicio = item.agendamento.horaInicio.toLocal();
    final fim = item.agendamento.horaFim.toLocal();
    final mesmoDia =
        inicio.year == fim.year &&
        inicio.month == fim.month &&
        inicio.day == fim.day;

    if (mesmoDia) {
      return '${_data(inicio)} · ${_hora(inicio)} – ${_hora(fim)}';
    }
    return '${_data(inicio)} ${_hora(inicio)} → ${_data(fim)} ${_hora(fim)}';
  }

  String _cep(String cep) {
    final digitos = cep.replaceAll(RegExp(r'\D'), '');
    if (digitos.length != 8) return cep;
    return '${digitos.substring(0, 5)}-${digitos.substring(5)}';
  }

  String _enderecoLinha1() {
    final a = item.agendamento;
    final complemento = a.enderecoComplemento?.trim();
    final base = '${a.enderecoLogradouro}, ${a.enderecoNumero}';
    if (complemento == null || complemento.isEmpty) return base;
    return '$base - $complemento';
  }

  String _enderecoLinha2() {
    final a = item.agendamento;
    return '${a.enderecoBairro}, ${a.enderecoCidade}/${a.enderecoEstado}'
        ' · CEP ${_cep(a.enderecoCep)}';
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

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final a = item.agendamento;
    final corDestaque = _corDestaque(scheme);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Faixa fina superior indicando o grupo do status.
              Container(height: 4, color: corDestaque),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título + status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.nomeServico,
                            style: AppTextStyles.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        StatusBadge(status: a.status),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildContraparte(context),

                    const SizedBox(height: 14),
                    Divider(height: 1, color: scheme.outlineVariant),
                    const SizedBox(height: 14),

                    _info(
                      context,
                      icon: Icons.event_rounded,
                      titulo: 'Data e horário',
                      valor: _periodo(),
                    ),
                    const SizedBox(height: 12),

                    _info(
                      context,
                      icon: Icons.location_on_rounded,
                      titulo: 'Endereço',
                      valor: _enderecoLinha1(),
                      valorSecundario: _enderecoLinha2(),
                    ),

                    _buildHistorico(context),

                    const SizedBox(height: 14),
                    Divider(height: 1, color: scheme.outlineVariant),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Valor', style: AppTextStyles.legenda),
                            Text(
                              'R\$ ${a.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: AppTextStyles.titulo,
                            ),
                          ],
                        ),
                        const Spacer(),
                        _buildBotaoDetalhes(context),
                      ],
                    ),
                    Row(
                      children: [
                        Column(/* ...Valor... */),
                        const Spacer(),
                        _buildBotaoDetalhes(context),
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
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Partes
  // ---------------------------------------------------------------

  Widget _buildContraparte(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final avatarUrl = item.contraparteAvatarUrl;
    final temAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final rotulo = item.comoCliente ? 'Prestador' : 'Cliente';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.perfilPublico, arguments: item.contraParteId),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: scheme.primaryContainer,
              backgroundImage: temAvatar ? NetworkImage(avatarUrl) : null,
              child: temAvatar
                  ? null
                  : Text(
                      _iniciais(item.nomeContraparte),
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      rotulo.toUpperCase(),
                      style: AppTextStyles.legenda.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.nomeContraparte,
                          style: AppTextStyles.corpo.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.contraparteVerificada) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: scheme.primary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurfaceVariant,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String valor,
    String? valorSecundario,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: AppTextStyles.legenda),
              const SizedBox(height: 2),
              Text(valor, style: AppTextStyles.corpo),
              if (valorSecundario != null)
                Text(valorSecundario, style: AppTextStyles.legenda),
            ],
          ),
        ),
      ],
    );
  }

  /// Histórico de marcos, agora dentro de um ExpansionTile — some do
  /// caminho visual até quem quiser abrir, deixando o card mais limpo
  /// por padrão.
  Widget _buildHistorico(BuildContext context) {
    final a = item.agendamento;
    final scheme = Theme.of(context).colorScheme;

    final marcos = <(IconData, String, DateTime)>[
      (Icons.add_circle_outline_rounded, 'Solicitado', a.criadoEm),
      if (a.editadoEm != null) (Icons.edit_outlined, 'Editado', a.editadoEm!),
      if (a.horaInicioReal != null)
        (Icons.play_circle_outline_rounded, 'Iniciado', a.horaInicioReal!),
      if (a.horaConclusaoPrestador != null)
        (
          Icons.task_alt_rounded,
          'Concluído pelo prestador',
          a.horaConclusaoPrestador!,
        ),
      if (a.horaConfirmacaoUsuario != null)
        (
          Icons.check_circle_outline_rounded,
          'Confirmado pelo cliente',
          a.horaConfirmacaoUsuario!,
        ),
    ];

    if (marcos.length <= 1) return const SizedBox.shrink();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 4),
        title: Text('Histórico', style: AppTextStyles.legenda),
        iconColor: scheme.onSurfaceVariant,
        collapsedIconColor: scheme.onSurfaceVariant,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (var i = 0; i < marcos.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        marcos[i].$1,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(marcos[i].$2, style: AppTextStyles.legenda),
                      ),
                      Text(
                        _dataHora(marcos[i].$3),
                        style: AppTextStyles.legenda,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoDetalhes(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ver detalhes',
            style: AppTextStyles.corpo.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.chevron_right_rounded,
            color: scheme.onPrimaryContainer,
            size: 18,
          ),
        ],
      ),
    );
  }
}
