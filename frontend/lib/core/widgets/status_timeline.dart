import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Linha do tempo de acompanhamento para denúncias e contestações —
/// ambas compartilham os mesmos 4 valores de status ('aberta',
/// 'em_analise', 'resolvida', 'rejeitada'), então um único widget serve
/// pros dois fluxos.
///
/// Mostra 3 etapas: Aberta -> Em análise -> Resolvida (ou Rejeitada,
/// quando o desfecho já é negativo — nesse caso a última etapa troca de
/// rótulo e cor).
class StatusTimeline extends StatelessWidget {
  final String status;

  const StatusTimeline({super.key, required this.status});

  int get _indiceAtual {
    switch (status) {
      case 'aberta':
        return 0;
      case 'em_analise':
        return 1;
      case 'resolvida':
      case 'rejeitada':
        return 2;
      default:
        return 0;
    }
  }

  bool get _rejeitada => status == 'rejeitada';

  @override
  Widget build(BuildContext context) {
    final indiceAtual = _indiceAtual;

    final titulos = [
      'Aberta',
      'Em análise',
      _rejeitada ? 'Rejeitada' : 'Resolvida',
    ];
    final subtitulos = [
      'Recebemos sua solicitação',
      'Nossa equipe está avaliando',
      _rejeitada ? 'Não foi possível atender a solicitação' : 'Caso encerrado',
    ];
    final cores = [
      AppColors.primary,
      AppColors.primary,
      _rejeitada ? AppColors.error : AppColors.success,
    ];

    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          _EtapaTimeline(
            titulo: titulos[i],
            subtitulo: subtitulos[i],
            cor: cores[i],
            concluida: i < indiceAtual || (i == indiceAtual && i == 2),
            atual: i == indiceAtual && i != 2,
            ultima: i == 2,
          ),
      ],
    );
  }
}

class _EtapaTimeline extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Color cor;
  final bool concluida;
  final bool atual;
  final bool ultima;

  const _EtapaTimeline({
    required this.titulo,
    required this.subtitulo,
    required this.cor,
    required this.concluida,
    required this.atual,
    required this.ultima,
  });

  @override
  Widget build(BuildContext context) {
    final destacada = concluida || atual;
    final corCirculo = destacada ? cor : AppColors.outline;
    final corLinha = concluida ? cor : AppColors.outline;
    final corTexto = destacada
        ? AppColors.textoTitulo
        : AppColors.textoSecundario;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: concluida ? cor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: corCirculo, width: 2),
                ),
                child: concluida
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : atual
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cor,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
              if (!ultima)
                Expanded(child: Container(width: 2, color: corLinha)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: ultima ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppTextStyles.corpo.copyWith(
                      color: corTexto,
                      fontWeight: destacada ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitulo, style: AppTextStyles.legenda),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
