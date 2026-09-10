import 'package:ajudai/core/widgets/app_button.dart';
import 'package:ajudai/core/widgets/app_text_field.dart';
import 'package:ajudai/core/widgets/error_banner.dart';
import 'package:ajudai/core/ws/ws_message_stream.dart';
import 'package:flutter/material.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authRepository = AuthRepository();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _carregando = false;
  String? _erroGeral;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() {
      _carregando = true;
      _erroGeral = null;
    });

    try {
      await _authRepository.login(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      if (!mounted) return;
      // TODO: trocar pela rota inicial definitiva do app (home/tabs).
      Navigator.of(context).pushReplacementNamed(AppRoutes.meuPerfil);
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

  void _irParaCadastro() {
    Navigator.of(context).pushNamed(AppRoutes.cadastro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Entrar',
                  style: AppTextStyles.titulo,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ErrorBanner(mensagem: _erroGeral),
                AppTextField(
                  label: 'E-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Senha',
                  controller: _senhaController,
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Entrar',
                  loading: _carregando,
                  onPressed: _entrar,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _carregando ? null : _irParaCadastro,
                  child: Text(
                    'Não tem conta? Cadastre-se',
                    style: AppTextStyles.corpo,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}