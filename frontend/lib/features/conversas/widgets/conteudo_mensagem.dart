import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
import 'audio_mensagem.dart';
import 'falha_no_anexo.dart';
import 'video_mensagem.dart';

class ConteudoMensagem extends StatelessWidget {
  final MensagemComUrl mensagem;
  final bool minha;
  final String? avatarUrl;

  const ConteudoMensagem({
    required this.mensagem,
    required this.minha,
    required this.avatarUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (mensagem.mensagem.tipo == TipoConteudoMensagem.audio) {
      return AudioMensagem(
        url: mensagem.urlArquivo,
        avatarUrl: avatarUrl,
        minha: minha,
      );
    }

    final texto = mensagem.mensagem.texto;
    final url = mensagem.urlArquivo;
    final arquivo = mensagem.mensagem.arquivo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (url != null &&
            mensagem.mensagem.tipo == TipoConteudoMensagem.imagem)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              width: 260,
              height: 220,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const SizedBox(
                      width: 260,
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    ),
              errorBuilder: (context, error, stackTrace) =>
                  FalhaNoAnexo(nome: arquivo?.nomeOriginal),
            ),
          )
        else if (url != null &&
            mensagem.mensagem.tipo == TipoConteudoMensagem.video)
          VideoMensagem(url: url)
        else if (arquivo != null)
          FalhaNoAnexo(nome: arquivo.nomeOriginal)
        else if (texto == null || texto.isEmpty)
          Text(
            'Arquivo enviado',
            style: TextStyle(
              color: minha ? Colors.white : AppColors.textoTitulo,
            ),
          ),
        if (texto != null && texto.isNotEmpty) ...[
          if (url != null || arquivo != null) const SizedBox(height: 8),
          Text(
            texto,
            style: TextStyle(
              color: minha ? Colors.white : AppColors.textoTitulo,
            ),
          ),
        ],
      ],
    );
  }
}
