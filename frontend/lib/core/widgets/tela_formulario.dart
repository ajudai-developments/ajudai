import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';
import 'cabecalho_simples.dart';
import 'error_banner.dart';

/// Esqueleto padrão das telas de formulário empilhadas (contestação,
/// denúncia): cabeçalho vermelho arredondado, conteúdo rolável e botão de
/// ação fixo na base (padrão de apps como iFood/99 — o botão principal
/// nunca sai da tela, mesmo com o teclado aberto).
class TelaFormulario extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String rotuloBotao;
  final VoidCallback onEnviar;
  final bool enviando;

  /// Erro geral (servidor/rede), já traduzido por ErroMapper.
  final String? erro;
  final List<Widget> children;

  const TelaFormulario({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.rotuloBotao,
    required this.onEnviar,
    required this.children,
    this.enviando = false,
    this.erro,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            CabecalhoSimples(titulo: titulo, subtitulo: subtitulo),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  ErrorBanner(mensagem: erro),
                  ...children,
                ],
              ),
            ),
            _BarraAcao(
              rotulo: rotuloBotao,
              enviando: enviando,
              onPressed: onEnviar,
            ),
          ],
        ),
      ),
    );
  }
}

class _BarraAcao extends StatelessWidget {
  final String rotulo;
  final bool enviando;
  final VoidCallback onPressed;

  const _BarraAcao({
    required this.rotulo,
    required this.enviando,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SizedBox(
            width: double.infinity,
            child: AppButton(
              label: rotulo,
              loading: enviando,
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }
}

/// Aviso informativo suave (fundo rosado da marca + ícone).
class AvisoInformativo extends StatelessWidget {
  final String texto;
  final IconData icone;

  const AvisoInformativo({
    super.key,
    required this.texto,
    this.icone = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: AppTextStyles.corpo.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
