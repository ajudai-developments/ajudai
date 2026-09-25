import 'package:flutter/material.dart';

import '../../../core/errors/erro_mapper.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ws/ws_message_stream.dart';
import '../agendamento_acoes.dart';
import 'agendamento_com_detalhes.dart';
import 'dialogo_cancelar_agendamento.dart';

typedef ExecutarAcaoDoItem =
    Future<void> Function(AcaoAgendamento acao, {String? motivo});

class AcoesAgendamentoRow extends StatefulWidget {
  final AgendamentoComDetalhes item;
  final ExecutarAcaoDoItem onExecutarAcao;
  final VoidCallback onAvaliar;

  const AcoesAgendamentoRow({
    super.key,
    required this.item,
    required this.onExecutarAcao,
    required this.onAvaliar,
  });

  @override
  State<AcoesAgendamentoRow> createState() => _AcoesAgendamentoRowState();
}

class _AcoesAgendamentoRowState extends State<AcoesAgendamentoRow> {
  bool _executando = false;

  Future<void> _rodar(AcaoAgendamento acao, {String? motivo}) async {
    setState(() => _executando = true);
    try {
      await widget.onExecutarAcao(acao, motivo: motivo);
    } on WsErroException catch (e) {
      _mostrarErro(
        ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem),
      );
    } on WsTimeoutException {
      _mostrarErro('Não foi possível conectar ao servidor. Tente novamente.');
    } finally {
      if (mounted) setState(() => _executando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _cancelar() async {
    final motivo = await mostrarDialogoCancelarAgendamento(context);
    if (motivo == null) return;
    await _rodar(AcaoAgendamento.cancelar, motivo: motivo);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.item.agendamento;
    final acoes = AcoesAgendamento.calcular(
      status: a.status,
      horaInicio: a.horaInicio,
      horaFim: a.horaFim,
      comoPrestador: widget.item.comoPrestador,
    );

    final temAlgo =
        acoes.temAcaoPrincipal || acoes.podeCancelar || acoes.instrucao != null;
    if (!temAlgo) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (acoes.instrucao != null)
            Text(
              acoes.instrucao!,
              style: AppTextStyles.legenda.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          if (acoes.temAcaoPrincipal || acoes.podeCancelar) ...[
            if (acoes.instrucao != null) const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (acoes.podeRecusar)
                  OutlinedButton(
                    onPressed: _executando
                        ? null
                        : () => _rodar(AcaoAgendamento.recusar),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                    ),
                    child: const Text('Recusar'),
                  ),
                if (acoes.podeAceitar)
                  FilledButton(
                    onPressed: _executando
                        ? null
                        : () => _rodar(AcaoAgendamento.aceitar),
                    child: const Text('Aceitar'),
                  ),
                if (acoes.podeIniciar)
                  FilledButton.icon(
                    onPressed: _executando
                        ? null
                        : () => _rodar(AcaoAgendamento.iniciar),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Iniciar atendimento'),
                  ),
                if (acoes.podeConcluir)
                  FilledButton.icon(
                    onPressed: _executando
                        ? null
                        : () => _rodar(AcaoAgendamento.concluir),
                    icon: const Icon(Icons.task_alt_rounded, size: 18),
                    label: const Text('Concluir atendimento'),
                  ),
                if (acoes.podeConfirmarConclusao)
                  FilledButton.icon(
                    onPressed: _executando
                        ? null
                        : () => _rodar(AcaoAgendamento.confirmarConclusao),
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                    label: const Text('Confirmar conclusão'),
                  ),
                if (acoes.podeAvaliar)
                  OutlinedButton.icon(
                    onPressed: _executando ? null : widget.onAvaliar,
                    icon: const Icon(Icons.star_border_rounded, size: 18),
                    label: const Text('Avaliar'),
                  ),
                if (acoes.podeCancelar)
                  TextButton(
                    onPressed: _executando ? null : _cancelar,
                    style: TextButton.styleFrom(foregroundColor: scheme.error),
                    child: const Text('Cancelar'),
                  ),
                if (_executando)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
