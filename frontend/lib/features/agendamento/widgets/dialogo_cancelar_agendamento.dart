import 'package:flutter/material.dart';

import '../../../core/layout/responsivo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Diálogo pedindo o motivo do cancelamento. Retorna o motivo digitado,
/// ou `null` se o usuário desistiu.
Future<String?> mostrarDialogoCancelarAgendamento(BuildContext context) {
  final controller = TextEditingController();
  final web = context.usaLayoutWeb;

  return showDialog<String>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: web
          ? const EdgeInsets.symmetric(horizontal: 24, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: web ? 420 : double.infinity),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_busy_rounded,
                    size: 26,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Cancelar agendamento',
                textAlign: TextAlign.center,
                style: AppTextStyles.titulo.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                'Conte pra gente o motivo do cancelamento.',
                textAlign: TextAlign.center,
                style: AppTextStyles.corpo,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                style: AppTextStyles.corpo.copyWith(
                  color: AppColors.textoTitulo,
                ),
                decoration: InputDecoration(
                  hintText: 'Ex: imprevisto, mudança de horário...',
                  hintStyle: AppTextStyles.corpo.copyWith(
                    color: AppColors.textoSecundario,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceAlt,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    final motivo = controller.text.trim();
                    if (motivo.isEmpty) return;
                    Navigator.of(context).pop(motivo);
                  },
                  child: const Text('Confirmar cancelamento'),
                ),
              ),
              const SizedBox(height: 8),

              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textoSecundario,
                ),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
