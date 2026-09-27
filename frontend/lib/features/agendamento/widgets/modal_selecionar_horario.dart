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

  /// Um novo agendamento não pode começar dentro de um intervalo já
  /// ocupado — e também não pode começar EXATAMENTE no instante em que
  /// outro termina (o prestador precisa se deslocar até o próximo
  /// endereço, não pode simplesmente "teleportar" de um atendimento
  /// para o outro). Por isso os dois limites do intervalo ocupado
  /// contam como indisponíveis (`[inicio, fim]`, e não `[inicio, fim)`).
  bool _inicioIndisponivel(DateTime horaLocal) {
    if (horaLocal.isBefore(DateTime.now())) return true;
    final horaUtc = horaLocal.toUtc();
    return widget.horariosOcupados.any(
      (h) => !horaUtc.isBefore(h.horaInicio) && !horaUtc.isAfter(h.horaFim),
    );
  }

  /// Mesma regra acima, mas para o horário de término: um novo
  /// agendamento não pode terminar exatamente quando um ocupado começa,
  /// nem sobrepor (parcial ou totalmente) um intervalo já ocupado.
  bool _fimIndisponivel(DateTime inicioLocal, DateTime fimLocal) {
    if (!fimLocal.isAfter(inicioLocal)) return true;
    final inicioUtc = inicioLocal.toUtc();
    final fimUtc = fimLocal.toUtc();
    return widget.horariosOcupados.any(
      (h) => !inicioUtc.isAfter(h.horaFim) && !fimUtc.isBefore(h.horaInicio),
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

    // Só entram na grade os horários realmente disponíveis — os
    // indisponíveis não são mais exibidos (nem desabilitados).
    final horariosInicioDisponiveis = [
      for (final h in horariosDoDia)
        if (!_inicioIndisponivel(h)) h,
    ];
    final slotsInicio = [
      for (final h in horariosInicioDisponiveis)
        HorarioSlot(horario: h, desabilitado: false),
    ];

    final horariosFimDisponiveis = _horaInicio == null
        ? const <DateTime>[]
        : [
            for (final h in horariosDoDia)
              if (!_fimIndisponivel(_horaInicio!, h)) h,
          ];
    final slotsFim = [
      for (final h in horariosFimDisponiveis)
        HorarioSlot(horario: h, desabilitado: false),
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
                      const Text(
                        'Início',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      if (slotsInicio.isEmpty)
                        _mensagemSemHorarios()
                      else
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
                        if (slotsFim.isEmpty)
                          _mensagemSemHorarios()
                        else
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

  Widget _mensagemSemHorarios() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Nenhum horário disponível nesse dia.',
        style: TextStyle(color: Colors.black45, fontSize: 13.5),
      ),
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
