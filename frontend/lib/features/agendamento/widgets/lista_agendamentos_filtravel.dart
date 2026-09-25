import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_text_styles.dart';
import '../agendamento_acoes.dart';
import 'agendamento_card.dart';
import 'agendamento_com_detalhes.dart';
import 'agendamento_destaque_card.dart';

enum _Filtro { todos, ativos, concluidos, encerrados }

extension on _Filtro {
  String get rotulo {
    switch (this) {
      case _Filtro.todos:
        return 'Todos';
      case _Filtro.ativos:
        return 'Ativos';
      case _Filtro.concluidos:
        return 'Concluídos';
      case _Filtro.encerrados:
        return 'Encerrados';
    }
  }

  bool aceita(StatusAgendamento status) {
    switch (this) {
      case _Filtro.todos:
        return true;
      case _Filtro.ativos:
        return status == StatusAgendamento.pendente ||
            status == StatusAgendamento.aceito ||
            status == StatusAgendamento.emAndamento ||
            status == StatusAgendamento.aguardandoConfirmacao;
      case _Filtro.concluidos:
        return status == StatusAgendamento.concluido;
      case _Filtro.encerrados:
        return status == StatusAgendamento.recusado ||
            status == StatusAgendamento.cancelado ||
            status == StatusAgendamento.naoConcluido ||
            status == StatusAgendamento.contestado;
    }
  }
}

class ListaAgendamentosFiltravel extends StatefulWidget {
  final List<AgendamentoComDetalhes> itens;
  final void Function(AgendamentoComDetalhes item) onTapItem;
  final ExecutarAcaoAgendamento executarAcao;
  final void Function(AgendamentoComDetalhes item) onAvaliar;

  const ListaAgendamentosFiltravel({
    super.key,
    required this.itens,
    required this.onTapItem,
    required this.executarAcao,
    required this.onAvaliar,
  });

  @override
  State<ListaAgendamentosFiltravel> createState() =>
      _ListaAgendamentosFiltravelState();
}

class _ListaAgendamentosFiltravelState
    extends State<ListaAgendamentosFiltravel> {
  _Filtro _filtro = _Filtro.todos;
  late List<AgendamentoComDetalhes> _itens;

  @override
  void initState() {
    super.initState();
    _itens = List.of(widget.itens);
  }

  @override
  void didUpdateWidget(covariant ListaAgendamentosFiltravel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A tela recarregou (ex: pull-to-refresh) e nos deu uma lista nova.
    if (!identical(widget.itens, oldWidget.itens)) {
      _itens = List.of(widget.itens);
    }
  }

  /// Executa a ação, atualiza o item localmente (sem precisar recarregar
  /// tudo do backend) e, se foi o cliente confirmando a conclusão, já
  /// manda direto pra avaliação.
  Future<void> _executar(
    AgendamentoComDetalhes item,
    AcaoAgendamento acao, {
    String? motivo,
  }) async {
    final atualizado = await widget.executarAcao(item, acao, motivo: motivo);
    if (!mounted) return;

    final itemAtualizado = item.copyWith(agendamento: atualizado);
    setState(() {
      final idx = _itens.indexWhere(
        (i) => i.agendamento.id == item.agendamento.id,
      );
      if (idx != -1) _itens[idx] = itemAtualizado;
    });

    if (acao == AcaoAgendamento.confirmarConclusao &&
        atualizado.status == StatusAgendamento.concluido) {
      widget.onAvaliar(itemAtualizado);
    }
  }

  AgendamentoComDetalhes? get _destaque {
    final candidatos = _itens.where((i) {
      final status = i.agendamento.status;
      final ativo =
          status == StatusAgendamento.pendente ||
          status == StatusAgendamento.aceito ||
          status == StatusAgendamento.emAndamento ||
          status == StatusAgendamento.aguardandoConfirmacao;
      return ativo && i.agendamento.horaFim.isAfter(DateTime.now());
    }).toList();

    if (candidatos.isEmpty) return null;

    candidatos.sort((a, b) {
      final aEmAndamento =
          a.agendamento.status == StatusAgendamento.emAndamento;
      final bEmAndamento =
          b.agendamento.status == StatusAgendamento.emAndamento;
      if (aEmAndamento != bEmAndamento) return aEmAndamento ? -1 : 1;
      return a.agendamento.horaInicio.compareTo(b.agendamento.horaInicio);
    });

    return candidatos.first;
  }

  @override
  Widget build(BuildContext context) {
    final destaque = _destaque;

    final listaSemDestaque = destaque == null
        ? _itens
        : _itens
              .where((i) => i.agendamento.id != destaque.agendamento.id)
              .toList();

    final filtrados = listaSemDestaque
        .where((i) => _filtro.aceita(i.agendamento.status))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (destaque != null)
          AgendamentoDestaqueCard(
            item: destaque,
            onTap: () => widget.onTapItem(destaque),
            onExecutarAcao: (acao, {motivo}) =>
                _executar(destaque, acao, motivo: motivo),
            onAvaliar: () => widget.onAvaliar(destaque),
          ),
        const SizedBox(height: 8),
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
            AgendamentoCard(
              item: item,
              onTap: () => widget.onTapItem(item),
              onExecutarAcao: (acao, {motivo}) =>
                  _executar(item, acao, motivo: motivo),
              onAvaliar: () => widget.onAvaliar(item),
            ),
      ],
    );
  }

  Widget _buildFiltros() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final f in _Filtro.values) ...[
            _buildChip(f),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(_Filtro filtro) {
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
