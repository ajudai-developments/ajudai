import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/features/auth/widgets/auth_shell_web.dart';
import 'package:ajudai/features/auth/widgets/cadastro_endereco_step.dart';
import 'package:ajudai/features/auth/widgets/passos_indicator.dart';
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ajudai_logo.dart';
import 'widgets/cadastro_dados_step.dart';
import 'widgets/cadastro_foto_step.dart';

/// Fluxo de cadastro em 3 passos, todos dentro desta mesma rota:
///
/// 1. Dados básicos — cria a conta (é aqui que a sessão passa a existir).
/// 2. Endereço — opcional, pode pular.
/// 3. Foto de perfil — opcional, pode pular.
///
/// Depois do passo 1 a conta já foi criada, então não dá mais pra voltar
/// pro formulário (o botão voltar some e o voltar do sistema é ignorado).
/// Ao terminar o passo 3 (enviando a foto ou pulando) vai pra Home,
/// limpando a pilha de navegação.
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  static const _totalPassos = 3;

  int _passo = 0;

  void _avancar() {
    if (!mounted) return;

    if (_passo >= _totalPassos - 1) {
      _irParaHome();
      return;
    }
    setState(() => _passo++);
  }

  void _irParaHome() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  Widget _buildPasso() {
    switch (_passo) {
      case 0:
        return CadastroDadosStep(
          key: const ValueKey('passo-dados'),
          onCadastrado: _avancar,
        );
      case 1:
        return CadastroEnderecoStep(
          key: const ValueKey('passo-endereco'),
          onAvancar: _avancar,
        );
      default:
        return CadastroFotoStep(
          key: const ValueKey('passo-foto'),
          onConcluir: _avancar,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _passo == 0,
      child: context.usaLayoutWeb ? _buildWeb() : _buildMobile(),
    );
  }

  Widget _buildWeb() {
    return AuthShellWeb(
      titulo: 'Criar conta',
      larguraForm: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          PassosIndicador(
            total: _totalPassos,
            atual: _passo,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildPasso(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile() {
    // exatamente o Scaffold que você já tem hoje (sem o PopScope)
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: _passo == 0
                        ? IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          )
                        : null,
                  ),
                  const Expanded(child: Center(child: AjudaiLogo(altura: 56))),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            PassosIndicador(total: _totalPassos, atual: _passo),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildPasso(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
