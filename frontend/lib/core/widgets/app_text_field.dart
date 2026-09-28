import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Campo de texto padrão do app.
///
/// Visual preenchido, com cantos arredondados e borda vermelha no foco.
/// Todos os parâmetros novos são opcionais, então os usos antigos
/// (label + controller + erro etc.) continuam funcionando sem mudança.
///
/// Quando [obscureText] é true, o campo ganha sozinho o botão de
/// mostrar/ocultar senha.
class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String? erro;
  final TextInputType? keyboardType;
  final bool readOnly;

  /// Ícone à esquerda do campo.
  final IconData? icone;
  final String? hint;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.erro,
    this.keyboardType,
    this.readOnly = false,
    this.icone,
    this.hint,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _oculto = widget.obscureText;

  OutlineInputBorder _borda(Color cor, {double largura = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cor, width: largura),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _oculto,
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      textCapitalization: widget.textCapitalization,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.erro,
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIcon: widget.icone == null
            ? null
            : Icon(widget.icone, color: AppColors.textoSecundario, size: 20),
        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: () => setState(() => _oculto = !_oculto),
                icon: Icon(
                  _oculto
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textoSecundario,
                  size: 20,
                ),
              )
            : null,
        border: _borda(Colors.transparent),
        enabledBorder: _borda(Colors.transparent),
        focusedBorder: _borda(AppColors.primary, largura: 1.5),
        errorBorder: _borda(AppColors.error),
        focusedErrorBorder: _borda(AppColors.error, largura: 1.5),
      ),
    );
  }
}
