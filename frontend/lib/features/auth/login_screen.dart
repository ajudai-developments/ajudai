import 'package:ajudai/core/session/sessao.dart';
import 'package:flutter/material.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/layout/responsivo.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ajudai_logo.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import 'auth_repository.dart';
import 'widgets/auth_shell_web.dart';

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
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      setState(() => _erroGeral = 'Informe seu e-mail e sua senha.');
      return;
    }

    setState(() {
      _carregando = true;
      _erroGeral = null;
    });

    try {
      await _authRepository.login(email: email, senha: senha);

      if (!mounted) return;

      if (Sessao.instance.ehAdmin) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.adminDashboard, (route) => false);
        return;
      }
      if (Sessao.instance.estaBanido) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.meuPerfil, (route) => false);
        return;
      }

      Navigator.pop(context);
    } on WsErroException catch (e) {
      if (!mounted) return;
      setState(() {
        _erroGeral = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      if (!mounted) return;
      setState(() {
        _erroGeral = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _irParaCadastro() async {
    final concluiuCadastro = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.cadastro);

    if (!mounted || concluiuCadastro != true) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  /// Campos e botões — idêntico nos dois layouts.
  Widget _formulario() {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ErrorBanner(mensagem: _erroGeral),
          AppTextField(
            label: 'E-mail',
            controller: _emailController,
            icone: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Senha',
            controller: _senhaController,
            icone: Icons.lock_outline_rounded,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) {
              if (!_carregando) _entrar();
            },
          ),
          const SizedBox(height: 24),
          AppButton(label: 'Entrar', loading: _carregando, onPressed: _entrar),
          const SizedBox(height: 20),
          const _DivisorOu(),
          const SizedBox(height: 20),
          AppOutlinedButton(
            label: 'Criar conta',
            onPressed: _carregando ? null : _irParaCadastro,
          ),
        ],
      ),
    );
  }

  Widget _buildWeb(bool podeVoltar) {
    return AuthShellWeb(
      titulo: 'Bem-vindo de volta',
      subtitulo: 'Entre para agendar e acompanhar seus serviços.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _formulario(),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _carregando
                ? null
                : () => podeVoltar
                      ? Navigator.of(context).maybePop()
                      : Navigator.of(
                          context,
                        ).pushReplacementNamed(AppRoutes.home),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textoSecundario,
            ),
            child: Text(podeVoltar ? 'Voltar' : 'Continuar sem entrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(bool podeVoltar) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: podeVoltar
                    ? IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      )
                    : const SizedBox(height: 48),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(child: AjudaiLogo(altura: 112)),
                      const SizedBox(height: 28),
                      Text(
                        'Bem-vindo de volta',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.display,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entre para agendar e acompanhar seus serviços.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.corpo,
                      ),
                      const SizedBox(height: 28),
                      _formulario(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final podeVoltar = Navigator.of(context).canPop();
    return context.usaLayoutWeb
        ? _buildWeb(podeVoltar)
        : _buildMobile(podeVoltar);
  }
}

/// Linha "—— ou ——" entre a ação principal e a secundária.
class _DivisorOu extends StatelessWidget {
  const _DivisorOu();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(height: 1, color: AppColors.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou', style: AppTextStyles.legenda),
        ),
        const Expanded(child: Divider(height: 1, color: AppColors.outline)),
      ],
    );
  }
}
