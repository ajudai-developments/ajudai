// lib/src/features/agendamento/presentation/widgets/horario_selector.dart
import 'package:ajudai/src/core/theme/app_colors.dart';
import 'package:ajudai/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class HorarioSelector extends StatefulWidget {
  final Function(DateTime inicio, DateTime fim) onHorarioSelecionado;
  final DateTime? horarioInicioInicial;
  final DateTime? horarioFimInicial;

  const HorarioSelector({
    super.key,
    required this.onHorarioSelecionado,
    this.horarioInicioInicial,
    this.horarioFimInicial,
  });

  @override
  State<HorarioSelector> createState() => _HorarioSelectorState();
}

class _HorarioSelectorState extends State<HorarioSelector> {
  late DateTime _dataSelecionada;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFim;

  @override
  void initState() {
    super.initState();
    _dataSelecionada = widget.horarioInicioInicial ?? DateTime.now();
    _horaInicio = TimeOfDay.fromDateTime(
      widget.horarioInicioInicial ?? DateTime.now(),
    );
    _horaFim = TimeOfDay.fromDateTime(
      widget.horarioFimInicial ?? DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Data
        Text(
          'Data',
          style: AppTextStyles.label,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selecionarData,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.fundoCampo,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.cinzaEscuro,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd/MM/yyyy').format(_dataSelecionada),
                  style: AppTextStyles.corpo,
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.cinzaClaro,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Horário
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Início', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selecionarHora(true),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.fundoCampo,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: AppColors.cinzaEscuro,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _horaInicio.format(context),
                            style: AppTextStyles.corpo,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fim', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selecionarHora(false),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.fundoCampo,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: AppColors.cinzaEscuro,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _horaFim.format(context),
                            style: AppTextStyles.corpo,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Text(
          'Mínimo 30 minutos | Máximo 6 horas',
          style: AppTextStyles.secundario.copyWith(fontSize: 12),
        ),
        Text(
          'Das 06:00 às 23:00',
          style: AppTextStyles.secundario.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
      _notificarSelecao();
    }
  }

  Future<void> _selecionarHora(bool isInicio) async {
    final horaAtual = isInicio ? _horaInicio : _horaFim;
    final hora = await showTimePicker(
      context: context,
      initialTime: horaAtual,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: child!,
        );
      },
    );

    if (hora != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = hora;
          // Ajusta hora fim se necessário
          final inicioMin = _horaInicio.hour * 60 + _horaInicio.minute;
          final fimMin = _horaFim.hour * 60 + _horaFim.minute;
          if (fimMin <= inicioMin) {
            _horaFim = TimeOfDay(
              hour: _horaInicio.hour + 1,
              minute: _horaInicio.minute,
            );
          }
        } else {
          _horaFim = hora;
        }
      });
      _notificarSelecao();
    }
  }

  void _notificarSelecao() {
    final inicio = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      _horaInicio.hour,
      _horaInicio.minute,
    );
    final fim = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      _horaFim.hour,
      _horaFim.minute,
    );
    widget.onHorarioSelecionado(inicio, fim);
  }
}