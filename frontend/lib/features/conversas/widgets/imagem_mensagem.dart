import 'package:flutter/material.dart';

import 'falha_no_anexo.dart';
import 'tamanho_midia.dart';
import 'visualizador_imagem_url_screen.dart';

class ImagemMensagem extends StatefulWidget {
  final String url;
  final String? nomeArquivo;

  const ImagemMensagem({required this.url, this.nomeArquivo, super.key});

  @override
  State<ImagemMensagem> createState() => _ImagemMensagemState();
}

class _ImagemMensagemState extends State<ImagemMensagem> {
  static const _larguraMaxima = 250.0;
  static const _alturaMaxima = 300.0;

  double? _aspectRatio;
  bool _falhou = false;
  late final ImageStream _stream;
  late final ImageStreamListener _listener;

  @override
  void initState() {
    super.initState();
    _stream = Image.network(
      widget.url,
    ).image.resolve(const ImageConfiguration());
    _listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        setState(() {
          _aspectRatio = info.image.width / info.image.height;
        });
      },
      onError: (error, stackTrace) {
        if (!mounted) return;
        setState(() => _falhou = true);
      },
    );
    _stream.addListener(_listener);
  }

  @override
  void dispose() {
    _stream.removeListener(_listener);
    super.dispose();
  }

  void _abrirTelaCheia() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisualizadorImagemUrlScreen(url: widget.url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_falhou) {
      return FalhaNoAnexo(nome: widget.nomeArquivo);
    }

    final aspectRatio = _aspectRatio;
    final tamanho = aspectRatio == null
        ? const Size(_larguraMaxima, 190)
        : tamanhoMidiaChat(
            aspectRatio: aspectRatio,
            maxWidth: _larguraMaxima,
            maxHeight: _alturaMaxima,
          );

    return GestureDetector(
      onTap: _abrirTelaCheia,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: tamanho.width,
          height: tamanho.height,
          child: aspectRatio == null
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Image.network(widget.url, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
