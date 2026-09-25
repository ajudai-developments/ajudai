import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

/// Par de metadado + url assinada, na mesma ordem em que vieram do
/// backend (`contestacao.arquivos[i]` corresponde a `urls[i]`).
class ArquivoComUrl {
  final ArquivoAnexado arquivo;
  final String url;
  const ArquivoComUrl({required this.arquivo, required this.url});
}

/// Mostra os arquivos anexados a uma contestação (ou denúncia, etc.):
/// imagens em grade com zoom em tela cheia; áudio, vídeo e documento
/// como itens de lista que abrem no app/navegador padrão do aparelho.
class ArquivosAnexadosGrid extends StatelessWidget {
  final List<ArquivoAnexado> arquivos;
  final List<String> urls;

  const ArquivosAnexadosGrid({
    super.key,
    required this.arquivos,
    required this.urls,
  });

  List<ArquivoComUrl> get _pares => [
    for (var i = 0; i < arquivos.length && i < urls.length; i++)
      ArquivoComUrl(arquivo: arquivos[i], url: urls[i]),
  ];

  @override
  Widget build(BuildContext context) {
    final pares = _pares;
    if (pares.isEmpty) return const SizedBox.shrink();

    final imagens = pares
        .where((p) => p.arquivo.tipo == TipoArquivo.imagem)
        .toList();
    final outros = pares
        .where((p) => p.arquivo.tipo != TipoArquivo.imagem)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imagens.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: imagens.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final par = imagens[index];
              return GestureDetector(
                onTap: () => _abrirImagens(context, imagens, index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    par.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              );
            },
          ),
        if (imagens.isNotEmpty && outros.isNotEmpty) const SizedBox(height: 8),
        for (final par in outros) _ArquivoTile(par: par),
      ],
    );
  }

  void _abrirImagens(
    BuildContext context,
    List<ArquivoComUrl> imagens,
    int indiceInicial,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _VisualizadorImagensScreen(
          imagens: imagens,
          indiceInicial: indiceInicial,
        ),
      ),
    );
  }
}

class _ArquivoTile extends StatelessWidget {
  final ArquivoComUrl par;
  const _ArquivoTile({required this.par});

  IconData get _icone {
    switch (par.arquivo.tipo) {
      case TipoArquivo.audio:
        return Icons.audiotrack_outlined;
      case TipoArquivo.video:
        return Icons.videocam_outlined;
      case TipoArquivo.documento:
        return Icons.description_outlined;
      case TipoArquivo.imagem:
        return Icons.image_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => launchUrl(
            Uri.parse(par.url),
            mode: LaunchMode.externalApplication,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(_icone, color: Colors.grey.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    par.arquivo.nomeOriginal,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.open_in_new, size: 18, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VisualizadorImagensScreen extends StatefulWidget {
  final List<ArquivoComUrl> imagens;
  final int indiceInicial;

  const _VisualizadorImagensScreen({
    required this.imagens,
    required this.indiceInicial,
  });

  @override
  State<_VisualizadorImagensScreen> createState() =>
      _VisualizadorImagensScreenState();
}

class _VisualizadorImagensScreenState
    extends State<_VisualizadorImagensScreen> {
  late final PageController _controller;
  late int _indiceAtual;

  @override
  void initState() {
    super.initState();
    _indiceAtual = widget.indiceInicial;
    _controller = PageController(initialPage: _indiceAtual);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_indiceAtual + 1} de ${widget.imagens.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.imagens.length,
        onPageChanged: (i) => setState(() => _indiceAtual = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(child: Image.network(widget.imagens[index].url)),
          );
        },
      ),
    );
  }
}
