import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icone;
  final bool obscuro;
  final TextInputType? tipoTeclado;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? formatters;
  final TextInputAction? acaoTeclado;
  final void Function(String)? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icone,
    this.obscuro = false,
    this.tipoTeclado,
    this.validator,
    this.formatters,
    this.acaoTeclado,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _escondido = widget.obscuro;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _escondido,
      keyboardType: widget.tipoTeclado,
      inputFormatters: widget.formatters,
      validator: widget.validator,
      textInputAction: widget.acaoTeclado,
      onFieldSubmitted: widget.onSubmitted,
      style: const TextStyle(color: AppColors.pretoForte, fontSize: 15),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.icone != null
            ? Icon(widget.icone, color: AppColors.cinzaClaro, size: 20)
            : null,
        suffixIcon: widget.obscuro
            ? IconButton(
                icon: Icon(
                  _escondido ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.cinzaClaro,
                  size: 20,
                ),
                onPressed: () => setState(() => _escondido = !_escondido),
              )
            : null,
      ),
    );
  }
}
