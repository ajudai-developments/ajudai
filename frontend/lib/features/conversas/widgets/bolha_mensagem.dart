import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
import 'conteudo_mensagem.dart';

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
    final ehAudio = mensagem.mensagem.tipo == TipoConteudoMensagem.audio;
    final ehMidiaVisual =
        mensagem.mensagem.tipo == TipoConteudoMensagem.imagem ||
        mensagem.mensagem.tipo == TipoConteudoMensagem.video;
    final temLegenda =
        mensagem.mensagem.texto != null && mensagem.mensagem.texto!.isNotEmpty;
    // mídia visual sem legenda: o horário fica sobreposto na própria mídia
    final semPaddingExtra = ehAudio || (ehMidiaVisual && !temLegenda);

    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: semPaddingExtra
            ? const EdgeInsets.all(4)
            : const EdgeInsets.fromLTRB(14, 10, 12, 8),
        decoration: BoxDecoration(
          color: minha ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(minha ? 18 : 4),
            bottomRight: Radius.circular(minha ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConteudoMensagem(
              mensagem: mensagem,
              minha: minha,
              avatarUrl: avatarUrl,
              horario: horario,
            ),
            if (!semPaddingExtra)
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
