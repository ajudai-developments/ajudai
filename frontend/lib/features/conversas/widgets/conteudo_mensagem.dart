import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
import 'audio_mensagem.dart';
import 'falha_no_anexo.dart';
import 'imagem_mensagem.dart';
import 'video_mensagem.dart';

class ConteudoMensagem extends StatelessWidget {
  final MensagemComUrl mensagem;
  final bool minha;
  final String? avatarUrl;
  final String horario;

  const ConteudoMensagem({
    required this.mensagem,
    required this.minha,
    required this.avatarUrl,
    required this.horario,
    super.key,
  });

  Widget _selo() {
    return Positioned(
      right: 6,
      bottom: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          horario,
          style: const TextStyle(color: Colors.white, fontSize: 10.5),
        ),
      ),
    );
  }

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
    final temLegenda = texto != null && texto.isNotEmpty;
    final url = mensagem.urlArquivo;
    final arquivo = mensagem.mensagem.arquivo;
    final ehImagem =
        url != null && mensagem.mensagem.tipo == TipoConteudoMensagem.imagem;
    final ehVideo =
        url != null && mensagem.mensagem.tipo == TipoConteudoMensagem.video;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ehImagem)
          Stack(
            children: [
              ImagemMensagem(url: url, nomeArquivo: arquivo?.nomeOriginal),
              if (!temLegenda) _selo(),
            ],
          )
        else if (ehVideo)
          Stack(
            children: [
              VideoMensagem(url: url),
              if (!temLegenda) _selo(),
            ],
          )
        else if (arquivo != null)
          FalhaNoAnexo(nome: arquivo.nomeOriginal)
        else if (!temLegenda)
          Text(
            'Arquivo enviado',
            style: TextStyle(
              color: minha ? Colors.white : AppColors.textoTitulo,
            ),
          ),
        if (temLegenda) ...[
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
