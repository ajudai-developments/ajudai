import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'agendamento_com_detalhes.dart';

enum _NivelAlerta { calmo, atencao, urgente, emAndamento }

class _InfoAlerta {
  final String texto;
  final IconData icone;
  final _NivelAlerta nivel;
  const _InfoAlerta(this.texto, this.icone, this.nivel);
}

/// Aviso visual, sensível ao tempo, sobre o que está pendente naquele
/// agendamento AGORA.
///
/// A cor/urgência escala conforme o horário se aproxima ou passa, e o
/// TEXTO muda conforme o papel de quem está olhando — cliente vê o que
/// falta pro prestador fazer, prestador vê o que é esperado dele.
///
/// Só aparece nos status "vivos" do fluxo (pendente, aceito, em
/// andamento, aguardando confirmação); pra concluído/cancelado/recusado/
/// não-concluído/contestado não desenha nada.
class AgendamentoAlertaStatus extends StatefulWidget {
  final AgendamentoComDetalhes item;

  const AgendamentoAlertaStatus({super.key, required this.item});

  @override
  State<AgendamentoAlertaStatus> createState() =>
      _AgendamentoAlertaStatusState();
}

class _AgendamentoAlertaStatusState extends State<AgendamentoAlertaStatus>
    with SingleTickerProviderStateMixin {
  /// Quando faltar isso ou menos pro início, já mostra o aviso de
  /// "está quase começando" (independe da regra de negócio de quando
  /// o botão "Iniciar" libera — essa é só visual/informativa).
  static const _janelaAvisoProximo = Duration(minutes: 10);

  Timer? _timer;
  late final AnimationController _pulso;

  @override
  void initState() {
    super.initState();
    _pulso = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    // A mensagem depende de "agora", que muda sozinho — reavalia de
    // tempos em tempos pra não ficar com um aviso desatualizado até a
    // tela recarregar por outro motivo.
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulso.dispose();
    super.dispose();
  }

  _InfoAlerta? _calcular() {
    final a = widget.item.agendamento;
    final comoPrestador = widget.item.comoPrestador;
    final agora = DateTime.now();

    switch (a.status) {
      case StatusAgendamento.pendente:
        final restante = a.horaInicio.difference(agora);
        if (comoPrestador) {
          if (restante <= Duration.zero) {
            return const _InfoAlerta(
              'Pedido atrasado — o horário chegou e o cliente está esperando',
              Icons.notification_important_rounded,
              _NivelAlerta.urgente,
            );
          }
          if (restante <= const Duration(hours: 1)) {
            return const _InfoAlerta(
              'Esse pedido é urgente — aceite ou recuse logo',
              Icons.hourglass_bottom_rounded,
              _NivelAlerta.atencao,
            );
          }
          return const _InfoAlerta(
            'Novo pedido de agendamento aguardando sua resposta',
            Icons.mark_email_unread_outlined,
            _NivelAlerta.calmo,
          );
        }
        if (restante <= Duration.zero) {
          return const _InfoAlerta(
            'O horário chegou e seu pedido ainda não foi aceito',
            Icons.notification_important_rounded,
            _NivelAlerta.urgente,
          );
        }
        if (restante <= const Duration(hours: 1)) {
          return const _InfoAlerta(
            'Faltam poucos minutos e o prestador ainda não aceitou',
            Icons.hourglass_bottom_rounded,
            _NivelAlerta.atencao,
          );
        }
        return const _InfoAlerta(
          'Aguardando o prestador aceitar seu pedido',
          Icons.hourglass_empty_rounded,
          _NivelAlerta.calmo,
        );

      case StatusAgendamento.aceito:
        final jaComecou = !agora.isBefore(a.horaInicio);
        final faltaPouco =
            !jaComecou && a.horaInicio.difference(agora) <= _janelaAvisoProximo;

        if (comoPrestador) {
          if (jaComecou) {
            return const _InfoAlerta(
              'Você já pode iniciar o atendimento',
              Icons.play_circle_fill_rounded,
              _NivelAlerta.urgente,
            );
          }
          if (faltaPouco) {
            return const _InfoAlerta(
              'Seu atendimento está prestes a começar — prepare-se',
              Icons.notifications_active_rounded,
              _NivelAlerta.atencao,
            );
          }
          return const _InfoAlerta(
            'Atendimento confirmado — aguarde o horário',
            Icons.event_available_rounded,
            _NivelAlerta.calmo,
          );
        }
        if (jaComecou) {
          return const _InfoAlerta(
            'O horário chegou — aguardando o prestador iniciar',
            Icons.hourglass_bottom_rounded,
            _NivelAlerta.urgente,
          );
        }
        if (faltaPouco) {
          return const _InfoAlerta(
            'Seu serviço está prestes a iniciar — aguardando o prestador',
            Icons.notifications_active_rounded,
            _NivelAlerta.atencao,
          );
        }
        return const _InfoAlerta(
          'Prestador confirmado — aguarde o horário do atendimento',
          Icons.event_available_rounded,
          _NivelAlerta.calmo,
        );

      case StatusAgendamento.emAndamento:
        final terminou = agora.isAfter(a.horaFim);
        if (comoPrestador) {
          if (terminou) {
            return const _InfoAlerta(
              'O horário terminou — você já pode concluir o atendimento',
              Icons.task_alt_rounded,
              _NivelAlerta.atencao,
            );
          }
          return const _InfoAlerta(
            'Atendimento em andamento',
            Icons.play_circle_fill_rounded,
            _NivelAlerta.emAndamento,
          );
        }
        if (terminou) {
          return const _InfoAlerta(
            'O horário terminou — aguardando o prestador concluir',
            Icons.hourglass_bottom_rounded,
            _NivelAlerta.atencao,
          );
        }
        return const _InfoAlerta(
          'Atendimento em andamento',
          Icons.play_circle_fill_rounded,
          _NivelAlerta.emAndamento,
        );

      case StatusAgendamento.aguardandoConfirmacao:
        if (comoPrestador) {
          return const _InfoAlerta(
            'Aguardando o cliente confirmar a conclusão',
            Icons.hourglass_bottom_rounded,
            _NivelAlerta.calmo,
          );
        }
        return const _InfoAlerta(
          'Confirme a conclusão do atendimento',
          Icons.check_circle_outline_rounded,
          _NivelAlerta.urgente,
        );

      default:
        return null;
    }
  }

  Color _corDe(_NivelAlerta nivel) {
    switch (nivel) {
      case _NivelAlerta.calmo:
        return Colors.blue.shade600;
      case _NivelAlerta.atencao:
        return Colors.orange.shade700;
      case _NivelAlerta.urgente:
        return Colors.red.shade600;
      case _NivelAlerta.emAndamento:
        return Colors.green.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _calcular();
    if (info == null) return const SizedBox.shrink();

    final cor = _corDe(info.nivel);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulso,
            builder: (context, child) {
              final escala = 0.85 + (_pulso.value * 0.3);
              return Opacity(
                opacity: 0.6 + (_pulso.value * 0.4),
                child: Transform.scale(scale: escala, child: child),
              );
            },
            child: Icon(info.icone, size: 16, color: cor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info.texto,
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
