import 'package:ajudai/core/routes/app_routes.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import 'agendamento_com_detalhes.dart';
import 'status_badge.dart';

/// Card de um agendamento.
///
/// Reutilizado em: meus_agendamentos_screen e
/// agendamentos_recebidos_screen (o mesmo card serve pros dois lados,
/// cliente e prestador). O rótulo da contraparte muda conforme o papel:
/// quem vê como cliente enxerga o "Prestador", e vice-versa.
class AgendamentoCard extends StatelessWidget {
  final AgendamentoComDetalhes item;
  final VoidCallback onTap;

  const AgendamentoCard({super.key, required this.item, required this.onTap});

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

  /// Mesmo dia: "24/09/2026 · 14:00 – 16:00".
  /// Dias diferentes: "24/09/2026 14:00 → 25/09/2026 16:00".
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

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final a = item.agendamento;

    return Card(
      elevation: 0,
      color: scheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
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

              // Quando
              _info(
                context,
                icon: Icons.event_rounded,
                titulo: 'Data e horário',
                valor: _periodo(),
              ),
              const SizedBox(height: 12),

              // Onde
              _info(
                context,
                icon: Icons.location_on_rounded,
                titulo: 'Endereço',
                valor: _enderecoLinha1(),
                valorSecundario: _enderecoLinha2(),
              ),

              ..._buildLinhaDoTempo(context),

              const SizedBox(height: 14),
              Divider(height: 1, color: scheme.outlineVariant),
              const SizedBox(height: 12),

              // Rodapé
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
                  Text(
                    'Ver detalhes',
                    style: AppTextStyles.corpo.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.primary,
                    size: 20,
                  ),
                ],
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

    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.perfilPublico, arguments: item.contraParteId),
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
                Text(rotulo, style: AppTextStyles.legenda),
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
        ],
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
        Icon(icon, size: 20, color: scheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: AppTextStyles.legenda),
              Text(valor, style: AppTextStyles.corpo),
              if (valorSecundario != null)
                Text(valorSecundario, style: AppTextStyles.legenda),
            ],
          ),
        ),
      ],
    );
  }

  /// Marcos do agendamento. Só mostra os que têm data, e nem aparece
  /// o bloco se não houver nenhum.
  List<Widget> _buildLinhaDoTempo(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final a = item.agendamento;

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

    return [
      const SizedBox(height: 14),
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
                  Icon(marcos[i].$1, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(marcos[i].$2, style: AppTextStyles.legenda),
                  ),
                  Text(_dataHora(marcos[i].$3), style: AppTextStyles.legenda),
                ],
              ),
            ],
          ],
        ),
      ),
    ];
  }
}
