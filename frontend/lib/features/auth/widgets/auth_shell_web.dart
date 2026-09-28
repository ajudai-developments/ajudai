import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/theme/app_colors.dart';
import 'package:ajudai/core/theme/app_text_styles.dart';
import 'package:ajudai/core/widgets/ajudai_logo.dart';
import 'package:flutter/material.dart';

/// Layout web das telas de autenticação: painel de marca à esquerda
/// (só no desktop) e o formulário em um card centralizado à direita.
class AuthShellWeb extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget child;
  final double larguraForm;

  const AuthShellWeb({
    super.key,
    required this.titulo,
    required this.child,
    this.subtitulo,
    this.larguraForm = 440,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = context.ehDesktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (desktop) const Expanded(flex: 5, child: _PainelMarca()),
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: larguraForm),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!desktop) ...[
                          const Center(child: AjudaiLogo(altura: 72)),
                          const SizedBox(height: 20),
                        ],
                        Text(titulo, style: AppTextStyles.display),
                        if (subtitulo != null) ...[
                          const SizedBox(height: 6),
                          Text(subtitulo!, style: AppTextStyles.corpo),
                        ],
                        const SizedBox(height: 24),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PainelMarca extends StatelessWidget {
  const _PainelMarca();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.all(64),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajudaí',
            style: AppTextStyles.display.copyWith(
              color: Colors.white,
              fontSize: 48,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Encontre quem resolve o que você precisa.',
            style: AppTextStyles.corpo.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
