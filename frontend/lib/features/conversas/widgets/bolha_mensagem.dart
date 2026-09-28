import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
import 'conteudo_mensagem.dart';

/// Bolha de uma mensagem do chat.
///
/// - minha: vermelho da marca, texto branco;
/// - recebida: cinza claro ([AppColors.surfaceAlt]), texto escuro.
///
/// Foto/vídeo sem legenda ficam "colados" na bolha, com o horário
/// sobreposto na própria mídia. Todo o resto (texto, áudio, mídia com
/// legenda) mostra o horário embaixo, à direita.
class BolhaMensagem extends StatelessWidget {
  final MensagemComUrl mensagem;
  final bool minha;
  final String horario;
  final String? avatarUrl;

  const BolhaMensagem({
    required this.mensagem,
    required this.minha,
    required this.horario,
    required this.avatarUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tipo = mensagem.mensagem.tipo;
    final ehAudio = tipo == TipoConteudoMensagem.audio;
    final ehMidiaVisual =
        tipo == TipoConteudoMensagem.imagem ||
        tipo == TipoConteudoMensagem.video;
    final temLegenda =
        mensagem.mensagem.texto != null && mensagem.mensagem.texto!.isNotEmpty;

    // mídia visual sem legenda: o horário fica sobreposto na própria mídia
    final horarioSobreposto = ehMidiaVisual && !temLegenda;

    final EdgeInsets padding;
    if (horarioSobreposto) {
      padding = const EdgeInsets.all(4);
    } else if (ehAudio) {
      padding = const EdgeInsets.fromLTRB(10, 10, 12, 8);
    } else {
      padding = const EdgeInsets.fromLTRB(14, 10, 12, 8);
    }

    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding: padding,
        decoration: BoxDecoration(
          color: minha ? AppColors.primary : AppColors.surfaceAlt,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(minha ? 18 : 4),
            bottomRight: Radius.circular(minha ? 4 : 18),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConteudoMensagem(
              mensagem: mensagem,
              minha: minha,
              avatarUrl: avatarUrl,
              horario: horario,
            ),
            if (!horarioSobreposto)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  horario,
                  style: TextStyle(
                    fontSize: 11,
                    color: minha ? Colors.white70 : AppColors.textoSecundario,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
