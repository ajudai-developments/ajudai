import 'package:ajudai/core/theme/app_colors.dart';
import 'package:ajudai/core/theme/app_text_styles.dart';
import 'package:ajudai/core/widgets/app_text_field.dart';
import 'package:ajudai/core/widgets/secao_card.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

String formatarDataHora(DateTime d) {
  final l = d.toLocal();
  String p(int n) => n.toString().padLeft(2, '0');
  return '${p(l.day)}/${p(l.month)}/${l.year} ${p(l.hour)}:${p(l.minute)}';
}

String formatarValor(double v) =>
    'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

String labelStatusAgendamento(StatusAgendamento s) {
  switch (s) {
    case StatusAgendamento.pendente:
      return 'Pendente';
    case StatusAgendamento.aceito:
      return 'Aceito';
    case StatusAgendamento.emAndamento:
      return 'Em andamento';
    case StatusAgendamento.recusado:
      return 'Recusado';
    case StatusAgendamento.cancelado:
      return 'Cancelado';
    case StatusAgendamento.aguardandoConfirmacao:
      return 'Aguardando confirmação';
    case StatusAgendamento.concluido:
      return 'Concluído';
    case StatusAgendamento.naoConcluido:
      return 'Não concluído';
    case StatusAgendamento.contestado:
      return 'Contestado';
  }
}

/// Badge genérico (mesmo visual do StatusChip, com cor/rótulo livres).
class ChipAdmin extends StatelessWidget {
  final String label;
  final Color cor;
  const ChipAdmin({super.key, required this.label, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: cor, fontSize: 11),
      ),
    );
  }
}

/// Título grande do painel de detalhe (nome + subtítulo + badge à direita).
class CabecalhoDetalhe extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Widget? trailing;
  const CabecalhoDetalhe({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: AppTextStyles.display),
                const SizedBox(height: 4),
                Text(subtitulo, style: AppTextStyles.corpo),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 16), trailing!],
        ],
      ),
    );
  }
}

/// Seção do detalhe: rótulo em cima + conteúdo (normalmente um SecaoCard).
class SecaoAdmin extends StatelessWidget {
  final String titulo;
  final Widget child;
  const SecaoAdmin({super.key, required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: AppTextStyles.titulo),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// SecaoCard com várias [LinhaInfo] separadas por espaço.
class BlocoInfo extends StatelessWidget {
  final List<MapEntry<String, String>> linhas;
  const BlocoInfo({super.key, required this.linhas});

  @override
  Widget build(BuildContext context) {
    return SecaoCard(
      child: Column(
        children: [
          for (var i = 0; i < linhas.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            LinhaInfo(label: linhas[i].key, valor: linhas[i].value),
          ],
        ],
      ),
    );
  }
}

/// Dialog que pede um texto obrigatório (ex: motivo de rejeição).
/// Devolve o texto digitado, ou null se cancelado.
Future<String?> pedirTexto(
  BuildContext context, {
  required String titulo,
  required String rotulo,
  String confirmar = 'Confirmar',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) =>
        _DialogTexto(titulo: titulo, rotulo: rotulo, confirmar: confirmar),
  );
}

class _DialogTexto extends StatefulWidget {
  final String titulo;
  final String rotulo;
  final String confirmar;
  const _DialogTexto({
    required this.titulo,
    required this.rotulo,
    required this.confirmar,
  });

  @override
  State<_DialogTexto> createState() => _DialogTextoState();
}

class _DialogTextoState extends State<_DialogTexto> {
  final _controller = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) {
      setState(() => _erro = 'Campo obrigatório.');
      return;
    }
    Navigator.of(context).pop(texto);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(widget.titulo, style: AppTextStyles.titulo),
      content: SizedBox(
        width: 440,
        child: AppTextField(
          label: widget.rotulo,
          controller: _controller,
          maxLines: 4,
          minLines: 3,
          erro: _erro,
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirmar, child: Text(widget.confirmar)),
      ],
    );
  }
}
