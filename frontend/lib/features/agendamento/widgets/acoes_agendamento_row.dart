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

  /// Versão compacta pros cards de listagem (botões menores, sem
  /// texto de instrução — só o essencial pra caber várias linhas na
  /// tela). `false` (padrão) pro card de destaque e telas de detalhe.
  final bool denso;

  const AcoesAgendamentoRow({
    super.key,
    required this.item,
    required this.onExecutarAcao,
    required this.onAvaliar,
    this.denso = false,
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

    final temBotoes = acoes.temAcaoPrincipal || acoes.podeCancelar;
    // No modo denso, a instrução textual some — o card já fica
    // sobrecarregado com ela; nas telas de detalhe (não-denso) ela
    // continua aparecendo.
    final mostrarInstrucao = !widget.denso && acoes.instrucao != null;

    if (!temBotoes && !mostrarInstrucao) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    final estiloBase = widget.denso
        ? const ButtonStyleOverrides(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            minimumSize: Size(0, 30),
            fontSize: 12,
            iconSize: 14,
          )
        : const ButtonStyleOverrides(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            minimumSize: Size(0, 40),
            fontSize: 14,
            iconSize: 18,
          );

    return Padding(
      padding: EdgeInsets.only(top: widget.denso ? 8 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mostrarInstrucao)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                acoes.instrucao!,
                style: AppTextStyles.legenda.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          if (temBotoes)
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
                    style: estiloBase.outlined(foregroundColor: scheme.error),
                    child: const Text('Recusar'),
                  ),
                if (acoes.podeAceitar)
                  FilledButton(
                    onPressed: _executando
                        ? null
                        : () => _rodar(AcaoAgendamento.aceitar),
                    style: estiloBase.filled(),
                    child: const Text('Aceitar'),
                  ),
                if (acoes.podeIniciar)
                  FilledButton.icon(
                    onPressed: _executando
                        ? null
                        : () => _rodar(AcaoAgendamento.iniciar),
                    style: estiloBase.filled(),
                    icon: Icon(
                      Icons.play_arrow_rounded,
                      size: estiloBase.iconSize,
                    ),
                    label: const Text('Iniciar'),
                  ),
                if (acoes.podeConcluir)
                  FilledButton.icon(
                    onPressed: _executando
                        ? null
                        : () => _rodar(AcaoAgendamento.concluir),
                    style: estiloBase.filled(),
                    icon: Icon(
                      Icons.task_alt_rounded,
                      size: estiloBase.iconSize,
                    ),
                    label: const Text('Concluir'),
                  ),
                if (acoes.podeConfirmarConclusao)
                  FilledButton.icon(
                    onPressed: _executando
                        ? null
                        : () => _rodar(AcaoAgendamento.confirmarConclusao),
                    style: estiloBase.filled(),
                    icon: Icon(
                      Icons.check_circle_outline_rounded,
                      size: estiloBase.iconSize,
                    ),
                    label: const Text('Confirmar'),
                  ),
                if (acoes.podeAvaliar)
                  OutlinedButton.icon(
                    onPressed: _executando ? null : widget.onAvaliar,
                    style: estiloBase.outlined(foregroundColor: scheme.primary),
                    icon: Icon(
                      Icons.star_border_rounded,
                      size: estiloBase.iconSize,
                    ),
                    label: const Text('Avaliar'),
                  ),
                if (acoes.podeCancelar)
                  TextButton(
                    onPressed: _executando ? null : _cancelar,
                    style: estiloBase.text(foregroundColor: scheme.error),
                    child: const Text('Cancelar'),
                  ),
                if (_executando)
                  SizedBox(
                    width: estiloBase.iconSize,
                    height: estiloBase.iconSize,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Conjunto de medidas pra gerar os `ButtonStyle` de cada variante
/// (filled/outlined/text) sem repetir os mesmos números em cada botão.
class ButtonStyleOverrides {
  final EdgeInsets padding;
  final Size minimumSize;
  final double fontSize;
  final double iconSize;

  const ButtonStyleOverrides({
    required this.padding,
    required this.minimumSize,
    required this.fontSize,
    required this.iconSize,
  });

  TextStyle get _textStyle =>
      TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700);

  ButtonStyle filled() => FilledButton.styleFrom(
    padding: padding,
    minimumSize: minimumSize,
    textStyle: _textStyle,
    visualDensity: VisualDensity.compact,
  );

  ButtonStyle outlined({required Color foregroundColor}) =>
      OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        padding: padding,
        minimumSize: minimumSize,
        textStyle: _textStyle,
        visualDensity: VisualDensity.compact,
      );

  ButtonStyle text({required Color foregroundColor}) => TextButton.styleFrom(
    foregroundColor: foregroundColor,
    padding: padding,
    minimumSize: minimumSize,
    textStyle: _textStyle,
    visualDensity: VisualDensity.compact,
  );
}
