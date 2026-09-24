import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'anexo_selecionado.dart';

/// Visualização em tela cheia de um anexo local:
/// - imagem: zoom com pinch e arrastar
/// - vídeo: play/pause, barra de progresso arrastável e duração
class VisualizadorAnexoScreen extends StatefulWidget {
  final String caminho;
  final TipoAnexo tipo;

  const VisualizadorAnexoScreen({
    required this.caminho,
    required this.tipo,
    super.key,
  });

  @override
  State<VisualizadorAnexoScreen> createState() =>
      _VisualizadorAnexoScreenState();
}

class _VisualizadorAnexoScreenState extends State<VisualizadorAnexoScreen> {
  VideoPlayerController? _video;

  @override
  void initState() {
    super.initState();
    if (widget.tipo == TipoAnexo.video) {
      final controller = VideoPlayerController.file(File(widget.caminho));
      _video = controller;
      controller
          .initialize()
          .then((_) {
            if (!mounted) return;
            controller
              ..setLooping(true)
              ..play();
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

  void _alternarReproducao(VideoPlayerController video) {
    video.value.isPlaying ? video.pause() : video.play();
  }

  Widget _conteudoImagem() {
    return Center(
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: Image.file(
          File(widget.caminho),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.broken_image_outlined,
            color: Colors.white70,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _conteudoVideo() {
    final video = _video;
    if (video == null || !video.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: video,
      builder: (context, value, _) {
        return Column(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _alternarReproducao(video),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: value.aspectRatio,
                        child: VideoPlayer(video),
                      ),
                      if (!value.isPlaying)
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0x99000000),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _alternarReproducao(video),
                      icon: Icon(
                        value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: VideoProgressIndicator(
                        video,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        colors: const VideoProgressColors(
                          playedColor: Colors.white,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_formatarDuracao(value.position)} / '
                      '${_formatarDuracao(value.duration)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: widget.tipo == TipoAnexo.imagem
          ? _conteudoImagem()
          : _conteudoVideo(),
    );
  }
}
