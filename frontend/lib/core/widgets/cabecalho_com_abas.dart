import 'package:flutter/material.dart';

import '../../features/agendamento/widgets/segmented_tab_bar.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Cabeçalho padrão das telas de listagem com abas: fundo vermelho com
/// cantos arredondados embaixo, título, subtítulo e a SegmentedTabBar
/// ancorada na base.
///
/// Reutilizado em MeusServicosOferecidosScreen, MeusAgendamentosScreen e
/// AgendamentosRecebidosScreen — qualquer tela nova de listagem com
/// abas deve usar este widget em vez de recriar o padrão.
class CabecalhoComAbas extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List<String> abas;
  final int abaSelecionada;
  final ValueChanged<int> onTrocarAba;

  /// Telas de topo (raiz da bottom nav, sem pilha de navegação) devem
  /// usar `false` aqui — não faz sentido mostrar seta de voltar quando
  /// não há pra onde voltar.
  final bool mostrarBotaoVoltar;

  const CabecalhoComAbas({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.abas,
    required this.abaSelecionada,
    required this.onTrocarAba,
    this.mostrarBotaoVoltar = true,
  });

  @override
  Widget build(BuildContext context) {
    final recuoEsquerdo = mostrarBotaoVoltar ? 12.0 : 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: EdgeInsets.fromLTRB(mostrarBotaoVoltar ? 4 : 20, 4, 20, 20),
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
              padding: EdgeInsets.only(left: recuoEsquerdo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppTextStyles.display.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: AppTextStyles.corpo.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: EdgeInsets.only(left: recuoEsquerdo),
              child: SegmentedTabBar(
                labels: abas,
                selectedIndex: abaSelecionada,
                onChanged: onTrocarAba,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
