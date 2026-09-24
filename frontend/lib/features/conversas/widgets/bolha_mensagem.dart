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

    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.fromLTRB(
          ehAudio ? 8 : 14,
          ehAudio ? 8 : 10,
          ehAudio ? 8 : 12,
          ehAudio ? 6 : 7,
        ),
        decoration: BoxDecoration(
          color: minha ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(minha ? 16 : 4),
            bottomRight: Radius.circular(minha ? 4 : 16),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 4,
              offset: Offset(0, 1),
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
            ),
            if (!ehAudio && mensagem.mensagem.texto != null)
              const SizedBox(height: 3),
            if (!ehAudio)
              Text(
                horario,
                style: TextStyle(
                  fontSize: 11,
                  color: minha ? Colors.white70 : AppColors.textoSecundario,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
