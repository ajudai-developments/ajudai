import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class LoginForm extends StatefulWidget {
  final bool carregando;
  final Future<void> Function(String email, String senha) onSubmit;

  const LoginForm({super.key, required this.carregando, required this.onSubmit});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(_emailController.text, _senhaController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _emailController,
            label: 'E-mail',
            icone: Icons.mail_outline,
            tipoTeclado: TextInputType.emailAddress,
            acaoTeclado: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Informe seu e-mail';
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                return 'E-mail inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _senhaController,
            label: 'Senha',
            icone: Icons.lock_outline,
            obscuro: true,
            acaoTeclado: TextInputAction.done,
            onSubmitted: (_) => _enviar(),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Informe sua senha' : null,
          ),
          const SizedBox(height: 28),
          AppButton(
            texto: 'Entrar',
            carregando: widget.carregando,
            onPressed: _enviar,
          ),
        ],
      ),
    );
  }
}
