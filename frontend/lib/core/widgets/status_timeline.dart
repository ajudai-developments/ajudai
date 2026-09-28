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
/// Todo o destaque usa o vermelho da marca ([AppColors.primary]); o que
/// diferencia os desfechos é o caminho destacado, o cartão preenchido e o
/// ícone (check vs. X), não a cor.
///
/// Enquanto o caso ainda não chegou a um desfecho (status 'aberta' ou
/// 'em_analise'), a etapa atual pulsa — se o status já for 'resolvida'
/// ou 'rejeitada', não há pulso (o caso já foi decidido).
class StatusTimeline extends StatefulWidget {
  final String status;

  final TimelineTextos textos;

  const StatusTimeline({
    super.key,
    required this.status,
    this.textos = const TimelineTextos(),
  });
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EtapaVertical(
          titulo: widget.textos.etapa1Titulo,
          subtitulo: widget.textos.etapa1Subtitulo,
          concluida: abertaConcluida,
          atual: abertaAtual,
          pulso: abertaAtual ? _pulso : null,
          corLinha: abertaConcluida ? AppColors.primary : AppColors.outline,
        ),
        _EtapaVertical(
          titulo: widget.textos.etapa1Titulo,
          subtitulo: widget.textos.etapa1Subtitulo,
          concluida: decidido,
          atual: analiseAtual,
          pulso: analiseAtual ? _pulso : null,
          // Linha que desce de "Em análise" até o garfo: vermelha assim que
          // o caso é decidido, pra trilha ficar contínua com o desfecho.
          corLinha: decidido ? AppColors.primary : AppColors.outline,
        ),
        _GarfoDesfecho(
          decidido: decidido,
          textos: widget.textos,
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
  /// refletir se o desfecho já foi decidido, não só "concluída ou não".
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
  final TimelineTextos textos;

  const _GarfoDesfecho({
    required this.textos,
    required this.decidido,
    required this.resolvidaEscolhida,
    required this.rejeitadaEscolhida,
  });
  @override
  Widget build(BuildContext context) {
    final corTronco = decidido ? AppColors.primary : AppColors.outline;

    final corBracoEsquerdo = resolvidaEscolhida
        ? AppColors.primary
        : AppColors.outline;
    final corBracoDireito = rejeitadaEscolhida
        ? AppColors.primary
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
                titulo: textos.positivoTitulo,
                subtitulo: textos.positivoSubtitulo,
                icone: Icons.check_circle_rounded,
                cor: AppColors.primary,
                escolhida: resolvidaEscolhida,
                esmaecida: decidido && !resolvidaEscolhida,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CartaoDesfecho(
                titulo: textos.positivoTitulo,
                subtitulo: textos.positivoSubtitulo,
                icone: Icons.cancel_rounded,
                cor: AppColors.primary,
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

/// Textos das etapas e dos dois desfechos da [StatusTimeline]. O padrão é
/// o de denúncias/contestações; outras telas passam o seu próprio.
class TimelineTextos {
  final String etapa1Titulo;
  final String etapa1Subtitulo;
  final String etapa2Titulo;
  final String etapa2Subtitulo;
  final String positivoTitulo;
  final String positivoSubtitulo;
  final String negativoTitulo;
  final String negativoSubtitulo;

  const TimelineTextos({
    this.etapa1Titulo = 'Aberta',
    this.etapa1Subtitulo = 'Recebemos sua solicitação',
    this.etapa2Titulo = 'Em análise',
    this.etapa2Subtitulo = 'Nossa equipe está avaliando',
    this.positivoTitulo = 'Resolvida',
    this.positivoSubtitulo = 'Caso encerrado a seu favor',
    this.negativoTitulo = 'Rejeitada',
    this.negativoSubtitulo = 'Solicitação não atendida',
  });

  static const verificacao = TimelineTextos(
    etapa1Titulo: 'Solicitação enviada',
    etapa1Subtitulo: 'Recebemos seus documentos',
    etapa2Titulo: 'Em análise',
    etapa2Subtitulo: 'Nossa equipe está verificando',
    positivoTitulo: 'Aprovada',
    positivoSubtitulo: 'Você já pode oferecer serviços',
    negativoTitulo: 'Rejeitada',
    negativoSubtitulo: 'Veja o motivo abaixo',
  );
}

/// Desenha o "garfo": um tronco vertical curto (continuação da linha da
/// última etapa) que se divide em dois braços, cada um descendo até o
/// centro do respectivo cartão de desfecho abaixo.
///
/// IMPORTANTE: usa [Canvas.drawRect] com coordenadas arredondadas pra
/// pixel inteiro em vez de [Canvas.drawLine]. Um traço (`drawLine`) numa
/// posição Y fracionária (ex: `9.9`) é espalhado pelo antialiasing entre
/// duas linhas de pixel, ficando bem mais claro/fraco que uma linha
/// vertical mais longa. Um retângulo preenchido com bordas inteiras não
/// sofre desse problema.
///
/// Atenção: o trecho horizontal centerX -> leftX é compartilhado pelos dois
/// caminhos, então o garfo é desenhado em segmentos que NÃO se sobrepõem
/// (cada pedaço tem uma única cor). A espessura (2px) é igual à das l  inhas
/// das etapas, pra tronco e linha anterior ficarem alinhados.
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
    const espessura = 2.0; // igual à linha das etapas (Container width: 2)
    const centerX = 12.0; // alinhado ao centro das bolinhas (24px) acima
    final midY = (size.height * 0.45).round().toDouble();
    final leftX = (size.width * 0.25).round().toDouble();
    final rightX = (size.width * 0.75).round().toDouble();
    final bottomY = size.height;
    const metade = espessura / 2;

    void linhaVertical(double x, double yInicio, double yFim, Color cor) {
      final topo = yInicio < yFim ? yInicio : yFim;
      final base = yInicio < yFim ? yFim : yInicio;
      canvas.drawRect(
        Rect.fromLTRB(x - metade, topo, x + metade, base),
        Paint()..color = cor,
      );
    }

    void linhaHorizontal(double xInicio, double xFim, double y, Color cor) {
      final esquerda = xInicio < xFim ? xInicio : xFim;
      final direita = xInicio < xFim ? xFim : xInicio;
      canvas.drawRect(
        Rect.fromLTRB(esquerda, y - metade, direita, y + metade),
        Paint()..color = cor,
      );
    }

    final esquerdaAtiva = corEsquerda != AppColors.outline;

    // Tronco: desce do topo até a base da linha horizontal.
    linhaVertical(centerX, 0, midY + metade, corTronco);

    // Horizontal 1: centerX -> leftX. Faz parte do caminho de QUALQUER
    // desfecho, então recebe a cor do desfecho ativo (ou cinza se nenhum).
    linhaHorizontal(
      centerX - metade,
      leftX + metade,
      midY,
      esquerdaAtiva ? corEsquerda : corDireita,
    );

    // Horizontal 2: leftX -> rightX. Só pertence ao caminho da Rejeitada.
    linhaHorizontal(leftX + metade, rightX + metade, midY, corDireita);

    // Descidas: começam logo abaixo da horizontal, sem cobrir ninguém.
    linhaVertical(leftX, midY + metade, bottomY, corEsquerda);
    linhaVertical(rightX, midY + metade, bottomY, corDireita);
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
