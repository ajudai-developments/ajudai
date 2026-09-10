import 'package:ajudai/core/widgets/app_button.dart';
import 'package:ajudai/core/widgets/app_text_field.dart';
import 'package:ajudai/core/widgets/error_banner.dart';
import 'package:ajudai/core/ws/ws_message_stream.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth_repository.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _authRepository = AuthRepository();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();

  bool _carregando = false;
  String? _erroGeral;
  String? _erroCpf;
  String? _erroTelefone;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  /// Valida CPF (obrigatório) e telefone (opcional, mas se preenchido
  /// precisa ser válido) usando os validators do `shared`.
  /// Retorna true se pode prosseguir com o envio.
  bool _validarCamposLocais() {
    final cpf = _cpfController.text;
    final telefone = _telefoneController.text.trim();

    setState(() {
      _erroCpf = CpfValidator.isValido(cpf) ? null : 'CPF inválido.';
      _erroTelefone = (telefone.isEmpty || TelefoneValidator.isValido(telefone))
          ? null
          : 'Telefone inválido.';
    });

    return _erroCpf == null && _erroTelefone == null;
  }

  Future<void> _cadastrar() async {
    if (!_validarCamposLocais()) return;

    setState(() {
      _carregando = true;
      _erroGeral = null;
    });

    final telefone = _telefoneController.text.trim();

    try {
      await _authRepository.cadastrar(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
        nome: _nomeController.text.trim(),
        cpf: _cpfController.text,
        telefone: telefone.isEmpty ? null : telefone,
      );

      if (!mounted) return;
      // TODO: trocar pela rota inicial definitiva do app (home/tabs).
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on WsErroException catch (e) {
      setState(() {
        _erroGeral = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() {
        _erroGeral = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Criar conta', style: AppTextStyles.titulo, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ErrorBanner(mensagem: _erroGeral),
              AppTextField(label: 'Nome completo', controller: _nomeController),
              const SizedBox(height: 16),
              AppTextField(
                label: 'E-mail',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              AppTextField(label: 'Senha', controller: _senhaController, obscureText: true),
              const SizedBox(height: 16),
              AppTextField(
                label: 'CPF',
                controller: _cpfController,
                keyboardType: TextInputType.number,
                erro: _erroCpf,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Telefone (opcional)',
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                erro: _erroTelefone,
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Cadastrar', loading: _carregando, onPressed: _cadastrar),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _carregando ? null : () => Navigator.of(context).pop(),
                child: Text('Já tem conta? Entrar', style: AppTextStyles.corpo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}