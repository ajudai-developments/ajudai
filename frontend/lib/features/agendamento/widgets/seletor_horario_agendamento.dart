import 'package:ajudai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HorarioSlot {
  final DateTime horario;
  final bool desabilitado;

  const HorarioSlot({required this.horario, required this.desabilitado});
}

/// Grade de horários (intervalos fixos) pra escolher início/término.
/// Horários ocupados pelo prestador (ou já passados) aparecem riscados
/// e desabilitados.
class SeletorHorarioAgendamento extends StatelessWidget {
  final List<HorarioSlot> slots;
  final DateTime? selecionado;
  final ValueChanged<DateTime> onSelecionar;

  const SeletorHorarioAgendamento({
    required this.slots,
    required this.selecionado,
    required this.onSelecionar,
    super.key,
  });

  String _formatar(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final slot in slots)
          _ChipHorario(
            texto: _formatar(slot.horario),
            desabilitado: slot.desabilitado,
            selecionado:
                selecionado != null &&
                selecionado!.isAtSameMomentAs(slot.horario),
            onTap: slot.desabilitado ? null : () => onSelecionar(slot.horario),
          ),
      ],
    );
  }
}

class _ChipHorario extends StatelessWidget {
  final String texto;
  final bool desabilitado;
  final bool selecionado;
  final VoidCallback? onTap;

  const _ChipHorario({
    required this.texto,
    required this.desabilitado,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color corFundo;
    final Color corTexto;
    final Color corBorda;

    if (desabilitado) {
      corFundo = const Color(0xFFF1F1F1);
      corTexto = const Color(0xFFBDBDBD);
      corBorda = const Color(0xFFF1F1F1);
    } else if (selecionado) {
      corFundo = AppColors.primary;
      corTexto = Colors.white;
      corBorda = AppColors.primary;
    } else {
      corFundo = Colors.white;
      corTexto = Colors.black87;
      corBorda = const Color(0xFFE3E3E3);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: corBorda),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: corTexto,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            decoration: desabilitado ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
