import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'tamanho_midia.dart';
import 'visualizador_video_url_screen.dart';

class VideoMensagem extends StatefulWidget {
  final String url;

  const VideoMensagem({required this.url, super.key});

  @override
  State<VideoMensagem> createState() => _VideoMensagemState();
}

class _VideoMensagemState extends State<VideoMensagem> {
  static const _larguraMaxima = 250.0;
  static const _alturaMaxima = 300.0;

  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _abrirTelaCheia() {
    _controller.pause();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisualizadorVideoUrlScreen(url: widget.url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const SizedBox(
        width: _larguraMaxima,
        height: 190,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final tamanho = tamanhoMidiaChat(
      aspectRatio: _controller.value.aspectRatio,
      maxWidth: _larguraMaxima,
      maxHeight: _alturaMaxima,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: tamanho.width,
        height: tamanho.height,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
            if (!_controller.value.isPlaying)
              const IgnorePointer(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 46,
                ),
              ),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.black45,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _abrirTelaCheia,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.fullscreen,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
