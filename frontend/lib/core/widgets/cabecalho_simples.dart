import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Cabeçalho vermelho arredondado simples (botão de voltar + título +
/// subtítulo) — mesmo padrão visual de [CabecalhoComAbas], mas sem abas.
/// Usado em telas empilhadas: formulários, detalhes e listas de perfil
/// (contestações, denúncias, endereços, conversas).
class CabecalhoSimples extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  /// Use `false` em telas de topo (raiz da bottom nav), onde não há
  /// pra onde voltar.
  final bool mostrarBotaoVoltar;

  const CabecalhoSimples({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.mostrarBotaoVoltar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: EdgeInsets.fromLTRB(mostrarBotaoVoltar ? 4 : 20, 4, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mostrarBotaoVoltar)
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              )
            else
              const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(left: mostrarBotaoVoltar ? 16 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppTextStyles.display.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: AppTextStyles.corpo.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
