import 'package:flutter/material.dart';

/// Campo de texto padrão do app.
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String? erro;
  final TextInputType? keyboardType;
  final bool readOnly;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.erro,
    this.keyboardType,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        errorText: erro,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
