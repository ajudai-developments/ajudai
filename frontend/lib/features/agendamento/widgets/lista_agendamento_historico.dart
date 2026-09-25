import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_text_styles.dart';
import 'agendamento_com_detalhes.dart';
import 'agendamento_historico_card.dart';

enum _FiltroHistorico { todos, concluidos, cancelados }

extension on _FiltroHistorico {
  String get rotulo => switch (this) {
    _FiltroHistorico.todos => 'Todos',
    _FiltroHistorico.concluidos => 'Concluídos',
    _FiltroHistorico.cancelados => 'Cancelados',
  };

  bool aceita(StatusAgendamento status) => switch (this) {
    _FiltroHistorico.todos => true,
    _FiltroHistorico.concluidos => status == StatusAgendamento.concluido,
    _FiltroHistorico.cancelados => status == StatusAgendamento.cancelado,
  };
}

class ListaAgendamentosHistorico extends StatelessWidget {
  final List<AgendamentoComDetalhes> itens;
  final void Function(AgendamentoComDetalhes item) onTapItem;
  final void Function(AgendamentoComDetalhes item) onAvaliar;
  final void Function(AgendamentoComDetalhes item) onDenunciar;
  final void Function(AgendamentoComDetalhes item) onContestar;

  const ListaAgendamentosHistorico({
    super.key,
    required this.itens,
    required this.onTapItem,
    required this.onAvaliar,
    required this.onDenunciar,
    required this.onContestar,
  });

  @override
  Widget build(BuildContext context) {
    return _ListaComFiltro(
      itens: itens,
      onTapItem: onTapItem,
      onAvaliar: onAvaliar,
      onDenunciar: onDenunciar,
      onContestar: onContestar,
    );
  }
}

class _ListaComFiltro extends StatefulWidget {
  final List<AgendamentoComDetalhes> itens;
  final void Function(AgendamentoComDetalhes item) onTapItem;
  final void Function(AgendamentoComDetalhes item) onAvaliar;
  final void Function(AgendamentoComDetalhes item) onDenunciar;
  final void Function(AgendamentoComDetalhes item) onContestar;

  const _ListaComFiltro({
    required this.itens,
    required this.onTapItem,
    required this.onAvaliar,
    required this.onDenunciar,
    required this.onContestar,
  });

  @override
  State<_ListaComFiltro> createState() => _ListaComFiltroState();
}

class _ListaComFiltroState extends State<_ListaComFiltro> {
  _FiltroHistorico _filtro = _FiltroHistorico.todos;

  @override
  Widget build(BuildContext context) {
    final filtrados = widget.itens
        .where((i) => _filtro.aceita(i.agendamento.status))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _buildFiltros(),
        const SizedBox(height: 4),
        if (filtrados.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Center(
              child: Text(
                'Nenhum agendamento neste filtro.',
                style: AppTextStyles.corpo,
              ),
            ),
          )
        else
          for (final item in filtrados)
            AgendamentoHistoricoCard(
              item: item,
              onTap: () => widget.onTapItem(item),
              onAvaliar: widget.onAvaliar,
              onDenunciar: widget.onDenunciar,
              onContestar: widget.onContestar,
            ),
      ],
    );
  }

  Widget _buildFiltros() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final f in _FiltroHistorico.values) ...[
            _buildChip(f),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(_FiltroHistorico filtro) {
    final scheme = Theme.of(context).colorScheme;
    final selecionado = _filtro == filtro;

    return ChoiceChip(
      label: Text(filtro.rotulo),
      selected: selecionado,
      onSelected: (_) => setState(() => _filtro = filtro),
      backgroundColor: scheme.surfaceContainerHighest,
      selectedColor: scheme.primary,
      labelStyle: TextStyle(
        color: selecionado ? scheme.onPrimary : scheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide.none,
      ),
    );
  }
}
