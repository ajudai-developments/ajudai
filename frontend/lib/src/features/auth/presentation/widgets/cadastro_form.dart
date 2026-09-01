import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../validators/senha_validator.dart';

class CadastroForm extends StatefulWidget {
  final bool carregando;
  final Future<void> Function({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
    String? telefone,
  }) onSubmit;

  const CadastroForm({super.key, required this.carregando, required this.onSubmit});

  @override
  State<CadastroForm> createState() => _CadastroFormState();
}

class _CadastroFormState extends State<CadastroForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      nome: _nomeController.text,
      email: _emailController.text,
      senha: _senhaController.text,
      cpf: _cpfController.text,
      telefone: _telefoneController.text.trim().isEmpty
          ? null
          : _telefoneController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _nomeController,
            label: 'Nome completo',
            icone: Icons.person_outline,
            acaoTeclado: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().length < 3) ? 'Informe seu nome completo' : null,
          ),
          const SizedBox(height: 16),
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
            controller: _cpfController,
            label: 'CPF',
            icone: Icons.badge_outlined,
            tipoTeclado: TextInputType.number,
            acaoTeclado: TextInputAction.next,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe seu CPF';
              if (!CpfValidator.isValido(v)) return 'CPF inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _telefoneController,
            label: 'Telefone (opcional)',
            icone: Icons.phone_outlined,
            tipoTeclado: TextInputType.phone,
            acaoTeclado: TextInputAction.next,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              if (!TelefoneValidator.isValido(v)) return 'Telefone inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _senhaController,
            label: 'Senha',
            icone: Icons.lock_outline,
            obscuro: true,
            acaoTeclado: TextInputAction.next,
            validator: (v) => SenhaValidator.mensagemErro(v),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _confirmarSenhaController,
            label: 'Confirmar senha',
            icone: Icons.lock_outline,
            obscuro: true,
            acaoTeclado: TextInputAction.done,
            onSubmitted: (_) => _enviar(),
            validator: (v) {
              if (v != _senhaController.text) return 'As senhas não coincidem';
              return null;
            },
          ),
          const SizedBox(height: 28),
          AppButton(
            texto: 'Criar conta',
            carregando: widget.carregando,
            onPressed: _enviar,
          ),
        ],
      ),
    );
  }
}
