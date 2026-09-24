import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'anexo_selecionado.dart';
import 'visualizador_anexo_screen.dart';

/// Miniatura do anexo que aparece acima do campo de texto no composer.
/// - imagem: mostra a própria foto
/// - vídeo: mostra o primeiro frame, ícone de play e a duração
/// Tocar abre o arquivo em tela cheia.
class MiniaturaAnexo extends StatefulWidget {
  final AnexoSelecionado anexo;
  final VoidCallback onRemover;
  final bool desabilitado;
  final double tamanho;

  const MiniaturaAnexo({
    required this.anexo,
    required this.onRemover,
    this.desabilitado = false,
    this.tamanho = 110,
    super.key,
  });

  @override
  State<MiniaturaAnexo> createState() => _MiniaturaAnexoState();
}

class _MiniaturaAnexoState extends State<MiniaturaAnexo> {
  VideoPlayerController? _video;

  @override
  void initState() {
    super.initState();
    if (widget.anexo.tipo == TipoAnexo.video) {
      final controller = VideoPlayerController.file(
        File(widget.anexo.caminho),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _video = controller;
      controller
          .initialize()
          .then((_) {
            if (!mounted) return;
            controller.setVolume(0);
            setState(() {});
          })
          .catchError((_) {});
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  String _formatarDuracao(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _abrirTelaCheia() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisualizadorAnexoScreen(
          caminho: widget.anexo.caminho,
          tipo: widget.anexo.tipo,
        ),
      ),
    );
  }

  Widget _conteudo() {
    if (widget.anexo.tipo == TipoAnexo.imagem) {
      return Image.file(
        File(widget.anexo.caminho),
        fit: BoxFit.cover,
        cacheWidth: 400, // não decodifica a foto inteira só pra uma miniatura
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.white70),
        ),
      );
    }

    final video = _video;
    if (video == null || !video.value.isInitialized) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: video.value.size.width,
        height: video.value.size.height,
        child: VideoPlayer(video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ehVideo = widget.anexo.tipo == TipoAnexo.video;
    final video = _video;

    return SizedBox(
      width: widget.tamanho,
      height: widget.tamanho,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _abrirTelaCheia,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: Color(0xFF2A2A2A)),
                    _conteudo(),
                    if (ehVideo)
                      const Center(
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0x99000000),
                          child: Icon(Icons.play_arrow, color: Colors.white),
                        ),
                      ),
                    if (ehVideo && video != null && video.value.isInitialized)
                      Positioned(
                        left: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.videocam,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatarDuracao(video.value.duration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Tooltip(
              message: 'Remover anexo',
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.desabilitado ? null : widget.onRemover,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
