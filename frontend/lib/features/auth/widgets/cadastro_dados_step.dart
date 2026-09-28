import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/errors/erro_mapper.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mascara_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/ws/ws_message_stream.dart';
import '../auth_repository.dart';

/// Passo 1 do cadastro: dados básicos do perfil.
///
/// Campos separados em seções (Dados pessoais / Contato / Acesso). Ao
/// tocar em "Continuar" cria a conta; se der certo chama [onCadastrado]
/// e o fluxo segue pro passo do endereço.
class CadastroDadosStep extends StatefulWidget {
  final VoidCallback onCadastrado;

  const CadastroDadosStep({super.key, required this.onCadastrado});

  @override
  State<CadastroDadosStep> createState() => _CadastroDadosStepState();
}

class _CadastroDadosStepState extends State<CadastroDadosStep> {
  final _authRepository = AuthRepository();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _carregando = false;
  String? _erroGeral;
  String? _erroNome;
  String? _erroCpf;
  String? _erroEmail;
  String? _erroTelefone;
  String? _erroSenha;

  static final _regexEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// CPF sem a máscara (só os 11 dígitos), pra validar e enviar ao servidor.
  String get _cpfDigitos => _cpfController.text.replaceAll(RegExp(r'\D'), '');

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// Valida os campos localmente (CPF e telefone via validators do
  /// `shared`). Retorna true se pode prosseguir com o envio.
  bool _validar() {
    final nome = _nomeController.text.trim();
    final cpf = _cpfDigitos;
    final email = _emailController.text.trim();
    final telefone = _telefoneController.text.trim();
    final senha = _senhaController.text;

    setState(() {
      _erroNome = nome.isEmpty ? 'Informe seu nome completo.' : null;
      _erroCpf = CpfValidator.isValido(cpf) ? null : 'CPF inválido.';
      _erroEmail = _regexEmail.hasMatch(email) ? null : 'E-mail inválido.';
      _erroTelefone = (telefone.isEmpty || TelefoneValidator.isValido(telefone))
          ? null
          : 'Telefone inválido.';
      _erroSenha = senha.isEmpty ? 'Crie uma senha.' : null;
    });

    return _erroNome == null &&
        _erroCpf == null &&
        _erroEmail == null &&
        _erroTelefone == null &&
        _erroSenha == null;
  }

  Future<void> _continuar() async {
    if (!_validar()) return;

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
        cpf: _cpfDigitos,
        telefone: telefone.isEmpty ? null : telefone,
      );

      if (!mounted) return;
      widget.onCadastrado();
    } on WsErroException catch (e) {
      setState(() {
        _erroGeral = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
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
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Crie sua conta', style: AppTextStyles.display),
          const SizedBox(height: 6),
          Text(
            'Comece com seus dados básicos. Leva menos de um minuto.',
            style: AppTextStyles.corpo,
          ),
          const SizedBox(height: 24),
          ErrorBanner(mensagem: _erroGeral),

          const _Secao('Dados pessoais'),
          AppTextField(
            label: 'Nome completo',
            controller: _nomeController,
            icone: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            erro: _erroNome,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'CPF',
            controller: _cpfController,
            icone: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [MascaraFormatter.cpf],
            erro: _erroCpf,
          ),
          const SizedBox(height: 24),

          const _Secao('Contato'),
          AppTextField(
            label: 'E-mail',
            controller: _emailController,
            icone: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            erro: _erroEmail,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Telefone (opcional)',
            controller: _telefoneController,
            icone: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            erro: _erroTelefone,
          ),
          const SizedBox(height: 24),

          const _Secao('Acesso'),
          AppTextField(
            label: 'Senha',
            controller: _senhaController,
            icone: Icons.lock_outline_rounded,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onSubmitted: (_) {
              if (!_carregando) _continuar();
            },
            erro: _erroSenha,
          ),
          const SizedBox(height: 28),

          AppButton(
            label: 'Continuar',
            loading: _carregando,
            onPressed: _continuar,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _carregando ? null : () => Navigator.of(context).pop(),
            child: const Text('Já tem conta? Entrar'),
          ),
        ],
      ),
    );
  }
}

/// Título de seção do formulário.
class _Secao extends StatelessWidget {
  final String titulo;
  const _Secao(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(titulo, style: AppTextStyles.titulo.copyWith(fontSize: 15)),
    );
  }
}
