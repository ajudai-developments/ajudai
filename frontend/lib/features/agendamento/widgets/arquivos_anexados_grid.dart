import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

/// Par de metadado + url assinada, na mesma ordem em que vieram do
/// backend (`contestacao.arquivos[i]` corresponde a `urls[i]`).
///
/// `url` pode ser `null` quando o arquivo não foi encontrado no
/// storage (por exemplo, upload que falhou ou foi removido depois) —
/// nesse caso mostramos um placeholder em vez de quebrar a tela.
class ArquivoComUrl {
  final ArquivoAnexado arquivo;
  final String? url;
  const ArquivoComUrl({required this.arquivo, required this.url});

  bool get disponivel => url != null;
}

/// Mostra os arquivos anexados a uma contestação (ou denúncia, etc.):
/// imagens em grade com zoom em tela cheia; áudio, vídeo e documento
/// como itens de lista que abrem no app/navegador padrão do aparelho.
///
/// Arquivos cuja URL não pôde ser gerada (ausentes no storage) são
/// exibidos com um indicador de "indisponível", sem impedir a
/// visualização dos demais.
class ArquivosAnexadosGrid extends StatelessWidget {
  final List<ArquivoAnexado> arquivos;
  final List<String?> urls;

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

              if (!par.disponivel) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return GestureDetector(
                onTap: () => _abrirImagens(context, imagens, index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    par.url!,
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
    // Ao abrir o visualizador em tela cheia, considera só as imagens
    // que têm URL disponível — evita tentar exibir uma imagem nula.
    final disponiveis = imagens.where((p) => p.disponivel).toList();
    if (disponiveis.isEmpty) return;

    final tocada = imagens[indiceInicial];
    final indiceAjustado = tocada.disponivel ? disponiveis.indexOf(tocada) : 0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _VisualizadorImagensScreen(
          imagens: disponiveis,
          indiceInicial: indiceAjustado.clamp(0, disponiveis.length - 1),
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
    final disponivel = par.disponivel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: disponivel
              ? () => launchUrl(
                  Uri.parse(par.url!),
                  mode: LaunchMode.externalApplication,
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  _icone,
                  color: disponivel
                      ? Colors.grey.shade700
                      : Colors.grey.shade400,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    disponivel
                        ? par.arquivo.nomeOriginal
                        : '${par.arquivo.nomeOriginal} (indisponível)',
                    overflow: TextOverflow.ellipsis,
                    style: disponivel
                        ? null
                        : TextStyle(color: Colors.grey.shade400),
                  ),
                ),
                if (disponivel)
                  Icon(
                    Icons.open_in_new,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
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
          // Essa tela só recebe imagens já filtradas como disponíveis
          // (ver `_abrirImagens`), então `url` nunca é null aqui.
          return InteractiveViewer(
            child: Center(child: Image.network(widget.imagens[index].url!)),
          );
        },
      ),
    );
  }
}
