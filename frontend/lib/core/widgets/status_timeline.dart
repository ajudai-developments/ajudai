import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Linha do tempo de acompanhamento para denúncias e contestações.
///
/// Estrutura: duas etapas em sequência (Aberta -> Em análise) seguidas
/// de um "garfo" com os dois desfechos possíveis lado a lado (Resolvida
/// / Rejeitada) — só um deles de fato acontece, então ambos aparecem
/// como opções, com o desfecho real destacado e o outro esmaecido.
///
/// Enquanto o caso ainda não chegou a um desfecho (status 'aberta' ou
/// 'em_analise'), a etapa atual pulsa — se o status já for 'resolvida'
/// ou 'rejeitada', não há pulso (o caso já foi decidido).
class StatusTimeline extends StatefulWidget {
  final String status;

  const StatusTimeline({super.key, required this.status});

  @override
  State<StatusTimeline> createState() => _StatusTimelineState();
}

class _StatusTimelineState extends State<StatusTimeline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso;

  bool get _emAndamento =>
      widget.status == 'aberta' || widget.status == 'em_analise';

  @override
  void initState() {
    super.initState();
    _pulso = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (_emAndamento) _pulso.repeat();
  }

  @override
  void didUpdateWidget(covariant StatusTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_emAndamento && !_pulso.isAnimating) {
      _pulso.repeat();
    } else if (!_emAndamento && _pulso.isAnimating) {
      _pulso
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    final decidido = status == 'resolvida' || status == 'rejeitada';

    final abertaConcluida = status != 'aberta';
    final abertaAtual = status == 'aberta';
    final analiseAtual = status == 'em_analise';

    // Cor da linha que desce de "Em análise" até o garfo: enquanto não
    // decidido, segue o padrão das etapas anteriores (vermelho da marca);
    // uma vez decidido, já assume a cor do desfecho (verde/vermelho de
    // erro), pra a "trilha" ficar visualmente contínua com o resultado.
    final corLinhaAteGarfo = !decidido
        ? AppColors.primary
        : status == 'resolvida'
        ? AppColors.success
        : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EtapaVertical(
          titulo: 'Aberta',
          subtitulo: 'Recebemos sua solicitação',
          concluida: abertaConcluida,
          atual: abertaAtual,
          pulso: abertaAtual ? _pulso : null,
          corLinha: abertaConcluida ? AppColors.primary : AppColors.outline,
        ),
        _EtapaVertical(
          titulo: 'Em análise',
          subtitulo: 'Nossa equipe está avaliando',
          concluida: decidido,
          atual: analiseAtual,
          pulso: analiseAtual ? _pulso : null,
          corLinha: decidido ? corLinhaAteGarfo : AppColors.outline,
        ),
        _GarfoDesfecho(
          decidido: decidido,
          resolvidaEscolhida: status == 'resolvida',
          rejeitadaEscolhida: status == 'rejeitada',
        ),
      ],
    );
  }
}

/// Etapa da parte sequencial da timeline (Aberta / Em análise): bolinha +
/// linha vertical descendo até a próxima etapa (ou até o garfo).
class _EtapaVertical extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final bool concluida;
  final bool atual;

  /// Controller de pulso — só vem preenchido quando esta é a etapa
  /// atual, ativando o anel pulsante ao redor da bolinha.
  final AnimationController? pulso;

  /// Cor da linha vertical abaixo desta etapa. Recebida de fora (em vez
  /// de calculada aqui) porque a última etapa antes do garfo precisa
  /// refletir a cor do desfecho já decidido, não só "concluída ou não".
  final Color corLinha;

  const _EtapaVertical({
    required this.titulo,
    required this.subtitulo,
    required this.concluida,
    required this.atual,
    required this.pulso,
    required this.corLinha,
  });

  @override
  Widget build(BuildContext context) {
    final destacada = concluida || atual;
    final corBolinha = destacada ? AppColors.primary : AppColors.outline;
    final corTexto = destacada
        ? AppColors.textoTitulo
        : AppColors.textoSecundario;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                _BolinhaEtapa(
                  concluida: concluida,
                  atual: atual,
                  cor: corBolinha,
                  pulso: pulso,
                ),
                Expanded(child: Container(width: 2, color: corLinha)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
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

/// Bolinha da etapa. Quando [pulso] não é nulo, desenha um anel bem
/// visível que cresce e desaparece por trás da bolinha, em loop.
class _BolinhaEtapa extends StatelessWidget {
  final bool concluida;
  final bool atual;
  final Color cor;
  final AnimationController? pulso;

  const _BolinhaEtapa({
    required this.concluida,
    required this.atual,
    required this.cor,
    required this.pulso,
  });

  @override
  Widget build(BuildContext context) {
    final bolinha = Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: concluida ? cor : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: cor, width: 2),
      ),
      child: concluida
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : atual
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
            )
          : null,
    );

    final pulsoAtivo = pulso;
    if (pulsoAtivo == null) return bolinha;

    // Anel de pulso: começa um pouco maior que a bolinha (nunca do MESMO
    // tamanho — senão fica escondido atrás dela no início da animação) e
    // cresce até quase o dobro do diâmetro, com alpha inicial bem mais
    // alto (0.55) pra ser visível mesmo num círculo pequeno.
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: pulsoAtivo,
            builder: (context, child) {
              final t = pulsoAtivo.value; // 0 -> 1, em loop
              final tamanho = 24 + 20 * t;
              final alpha = (1 - t) * 0.55;
              return Container(
                width: tamanho,
                height: tamanho,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cor.withValues(alpha: alpha),
                ),
              );
            },
          ),
          bolinha,
        ],
      ),
    );
  }
}

/// Garfo com os dois desfechos possíveis (Resolvida / Rejeitada), lado a
/// lado — representando que são caminhos alternativos, não sequenciais.
/// O desfecho real (quando já existe) fica destacado; o outro, esmaecido.
class _GarfoDesfecho extends StatelessWidget {
  final bool decidido;
  final bool resolvidaEscolhida;
  final bool rejeitadaEscolhida;

  const _GarfoDesfecho({
    required this.decidido,
    required this.resolvidaEscolhida,
    required this.rejeitadaEscolhida,
  });

  @override
  Widget build(BuildContext context) {
    final corTronco = !decidido
        ? AppColors.outline
        : resolvidaEscolhida
        ? AppColors.success
        : AppColors.error;

    final corBracoEsquerdo = resolvidaEscolhida
        ? AppColors.success
        : AppColors.outline;
    final corBracoDireito = rejeitadaEscolhida
        ? AppColors.error
        : AppColors.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 22,
          width: double.infinity,
          child: CustomPaint(
            painter: _GarfoPainter(
              corTronco: corTronco,
              corEsquerda: corBracoEsquerdo,
              corDireita: corBracoDireito,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _CartaoDesfecho(
                titulo: 'Resolvida',
                subtitulo: 'Caso encerrado a seu favor',
                icone: Icons.check_circle_rounded,
                cor: AppColors.success,
                escolhida: resolvidaEscolhida,
                esmaecida: decidido && !resolvidaEscolhida,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CartaoDesfecho(
                titulo: 'Rejeitada',
                subtitulo: 'Solicitação não atendida',
                icone: Icons.cancel_rounded,
                cor: AppColors.error,
                escolhida: rejeitadaEscolhida,
                esmaecida: decidido && !rejeitadaEscolhida,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Desenha o "garfo": um tronco vertical curto (continuação da linha da
/// última etapa) que se divide em dois braços, cada um descendo até o
/// centro do respectivo cartão de desfecho abaixo.
///
/// IMPORTANTE: usa [Canvas.drawRect] com coordenadas arredondadas pra
/// pixel inteiro em vez de [Canvas.drawLine]. Um traço (`drawLine`) numa
/// posição Y fracionária (ex: `9.9`) é espalhado pelo antialiasing entre
/// duas linhas de pixel, ficando bem mais claro/fraco que uma linha
/// vertical mais longa — exatamente o motivo do trecho horizontal
/// aparecer "sem cor" enquanto o vertical aparecia sólido. Um retângulo
/// preenchido com bordas inteiras não sofre desse problema.
class _GarfoPainter extends CustomPainter {
  final Color corTronco;
  final Color corEsquerda;
  final Color corDireita;

  _GarfoPainter({
    required this.corTronco,
    required this.corEsquerda,
    required this.corDireita,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const espessura = 3.0;
    const centerX = 12.0; // alinhado ao centro das bolinhas (24px) acima
    final midY = (size.height * 0.45).round().toDouble();
    final leftX = (size.width * 0.25).round().toDouble();
    final rightX = (size.width * 0.75).round().toDouble();
    final bottomY = size.height;
    const metade = espessura / 2;

    void linhaVertical(double x, double yInicio, double yFim, Color cor) {
      canvas.drawRect(
        Rect.fromLTRB(x - metade, yInicio, x + metade, yFim),
        Paint()..color = cor,
      );
    }

    void linhaHorizontal(double xInicio, double xFim, double y, Color cor) {
      canvas.drawRect(
        Rect.fromLTRB(xInicio, y - metade, xFim, y + metade),
        Paint()..color = cor,
      );
    }

    // Tronco: desce do topo até a altura do garfo.
    linhaVertical(centerX, 0, midY, corTronco);

    // Braço esquerdo (Resolvida): horizontal até leftX, depois desce.
    linhaHorizontal(leftX, centerX, midY, corEsquerda);
    linhaVertical(leftX, midY, bottomY, corEsquerda);

    // Braço direito (Rejeitada): horizontal até rightX, depois desce.
    linhaHorizontal(centerX, rightX, midY, corDireita);
    linhaVertical(rightX, midY, bottomY, corDireita);
  }

  @override
  bool shouldRepaint(covariant _GarfoPainter oldDelegate) {
    return oldDelegate.corTronco != corTronco ||
        oldDelegate.corEsquerda != corEsquerda ||
        oldDelegate.corDireita != corDireita;
  }
}

/// Cartão de um dos desfechos possíveis (Resolvida ou Rejeitada).
class _CartaoDesfecho extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icone;
  final Color cor;
  final bool escolhida;
  final bool esmaecida;

  const _CartaoDesfecho({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.cor,
    required this.escolhida,
    required this.esmaecida,
  });

  @override
  Widget build(BuildContext context) {
    final corFundo = escolhida
        ? cor.withValues(alpha: 0.1)
        : Colors.transparent;
    final corBorda = escolhida ? cor.withValues(alpha: 0.4) : AppColors.outline;

    return Opacity(
      opacity: esmaecida ? 0.45 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: corBorda),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icone,
              size: 20,
              color: escolhida ? cor : AppColors.textoSecundario,
            ),
            const SizedBox(height: 6),
            Text(
              titulo,
              style: AppTextStyles.corpo.copyWith(
                fontWeight: FontWeight.w700,
                color: escolhida
                    ? AppColors.textoTitulo
                    : AppColors.textoSecundario,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitulo, style: AppTextStyles.legenda, maxLines: 2),
          ],
        ),
      ),
    );
  }
}
