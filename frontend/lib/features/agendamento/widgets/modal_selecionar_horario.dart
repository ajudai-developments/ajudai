import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'seletor_data_agendamento.dart';
import 'seletor_horario_agendamento.dart';

class SelecaoHorario {
  final DateTime dia;
  final DateTime horaInicio;
  final DateTime horaFim;

  const SelecaoHorario({
    required this.dia,
    required this.horaInicio,
    required this.horaFim,
  });
}

/// Abre o modal e devolve a seleção feita, ou null se o usuário cancelar.
Future<SelecaoHorario?> abrirModalSelecionarHorario({
  required BuildContext context,
  required DateTime diaInicial,
  required DateTime? horaInicioInicial,
  required DateTime? horaFimInicial,
  required List<HorarioOcupado> horariosOcupados,
  int diasFuturos = 30,
  int horaMinima = 7,
  int horaMaxima = 23,
  int passoMinutos = 10,
}) {
  return showModalBottomSheet<SelecaoHorario>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ModalSelecionarHorario(
      diaInicial: diaInicial,
      horaInicioInicial: horaInicioInicial,
      horaFimInicial: horaFimInicial,
      horariosOcupados: horariosOcupados,
      diasFuturos: diasFuturos,
      horaMinima: horaMinima,
      horaMaxima: horaMaxima,
      passoMinutos: passoMinutos,
    ),
  );
}

class _ModalSelecionarHorario extends StatefulWidget {
  final DateTime diaInicial;
  final DateTime? horaInicioInicial;
  final DateTime? horaFimInicial;
  final List<HorarioOcupado> horariosOcupados;
  final int diasFuturos;
  final int horaMinima;
  final int horaMaxima;
  final int passoMinutos;

  const _ModalSelecionarHorario({
    required this.diaInicial,
    required this.horaInicioInicial,
    required this.horaFimInicial,
    required this.horariosOcupados,
    required this.diasFuturos,
    required this.horaMinima,
    required this.horaMaxima,
    required this.passoMinutos,
  });

  @override
  State<_ModalSelecionarHorario> createState() =>
      _ModalSelecionarHorarioState();
}

class _ModalSelecionarHorarioState extends State<_ModalSelecionarHorario> {
  late DateTime _dia;
  DateTime? _horaInicio;
  DateTime? _horaFim;

  @override
  void initState() {
    super.initState();
    _dia = widget.diaInicial;
    _horaInicio = widget.horaInicioInicial;
    _horaFim = widget.horaFimInicial;
  }

  List<DateTime> _gerarHorariosDoDia(DateTime dia) {
    final horarios = <DateTime>[];
    var atual = DateTime(dia.year, dia.month, dia.day, widget.horaMinima);
    final limite = DateTime(dia.year, dia.month, dia.day, widget.horaMaxima);
    while (!atual.isAfter(limite)) {
      horarios.add(atual);
      atual = atual.add(Duration(minutes: widget.passoMinutos));
    }
    return horarios;
  }

  bool _inicioIndisponivel(DateTime horaLocal) {
    if (horaLocal.isBefore(DateTime.now())) return true;
    final horaUtc = horaLocal.toUtc();
    return widget.horariosOcupados.any(
      (h) => !horaUtc.isBefore(h.horaInicio) && horaUtc.isBefore(h.horaFim),
    );
  }

  bool _fimIndisponivel(DateTime inicioLocal, DateTime fimLocal) {
    if (!fimLocal.isAfter(inicioLocal)) return true;
    final inicioUtc = inicioLocal.toUtc();
    final fimUtc = fimLocal.toUtc();
    return widget.horariosOcupados.any(
      (h) => inicioUtc.isBefore(h.horaFim) && fimUtc.isAfter(h.horaInicio),
    );
  }

  void _selecionarDia(DateTime dia) {
    setState(() {
      _dia = dia;
      _horaInicio = null;
      _horaFim = null;
    });
  }

  void _selecionarInicio(DateTime hora) {
    setState(() => _horaInicio = hora);
  }

  void _trocarInicio() {
    setState(() {
      _horaInicio = null;
      _horaFim = null;
    });
  }

  void _trocarFim() {
    setState(() => _horaFim = null);
  }

  String _formatarHora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final horariosDoDia = _gerarHorariosDoDia(_dia);
    final slotsInicio = [
      for (final h in horariosDoDia)
        HorarioSlot(horario: h, desabilitado: _inicioIndisponivel(h)),
    ];
    final slotsFim = _horaInicio == null
        ? const <HorarioSlot>[]
        : [
            for (final h in horariosDoDia)
              HorarioSlot(
                horario: h,
                desabilitado: _fimIndisponivel(_horaInicio!, h),
              ),
          ];

    final podeConfirmar = _horaInicio != null && _horaFim != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  children: [
                    Text(
                      'Escolha a data e o horário',
                      style: AppTextStyles.titulo,
                    ),
                    const SizedBox(height: 16),
                    SeletorDataAgendamento(
                      dataSelecionada: _dia,
                      diasFuturos: widget.diasFuturos,
                      onSelecionar: _selecionarDia,
                    ),
                    const SizedBox(height: 24),

                    // ---- Início: chip resumido depois de escolhido, senão grid
                    if (_horaInicio != null)
                      _ChipHorarioEscolhido(
                        rotulo: 'Início',
                        valor: _formatarHora(_horaInicio!),
                        onTrocar: _trocarInicio,
                      )
                    else ...[
                      Row(
                        children: [
                          const Text(
                            'Início',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          _legendaIndisponivel(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SeletorHorarioAgendamento(
                        slots: slotsInicio,
                        selecionado: _horaInicio,
                        onSelecionar: _selecionarInicio,
                      ),
                    ],

                    // ---- Término: só aparece depois do início escolhido
                    if (_horaInicio != null) ...[
                      const SizedBox(height: 16),
                      if (_horaFim != null)
                        _ChipHorarioEscolhido(
                          rotulo: 'Término',
                          valor: _formatarHora(_horaFim!),
                          onTrocar: _trocarFim,
                        )
                      else ...[
                        const Text(
                          'Término',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        SeletorHorarioAgendamento(
                          slots: slotsFim,
                          selecionado: _horaFim,
                          onSelecionar: (h) => setState(() => _horaFim = h),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: podeConfirmar
                          ? () => Navigator.of(context).pop(
                              SelecaoHorario(
                                dia: _dia,
                                horaInicio: _horaInicio!,
                                horaFim: _horaFim!,
                              ),
                            )
                          : null,
                      child: const Text('Confirmar horário'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legendaIndisponivel() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        const Text(
          'Indisponível',
          style: TextStyle(fontSize: 11.5, color: Colors.black45),
        ),
      ],
    );
  }
}

/// Resumo do horário já escolhido (início ou término), com opção de trocar.
/// Substitui o grid de horários depois que a seleção é feita, mantendo o
/// fluxo em um passo de cada vez.
class _ChipHorarioEscolhido extends StatelessWidget {
  final String rotulo;
  final String valor;
  final VoidCallback onTrocar;

  const _ChipHorarioEscolhido({
    required this.rotulo,
    required this.valor,
    required this.onTrocar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            '$rotulo: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onTrocar,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Trocar', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
