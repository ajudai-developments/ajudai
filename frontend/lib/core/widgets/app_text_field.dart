import 'package:flutter/material.dart';

/// Campo de texto padrão do app.
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String? erro;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.erro,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        errorText: erro,
        border: const OutlineInputBorder(),
      ),
    );
  }
}