import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Visualização em tela cheia de um vídeo vindo de uma URL de rede,
/// com play/pause, barra de progresso arrastável e duração.
/// Usada ao abrir em tela cheia um vídeo já exibido numa bolha de mensagem.
class VisualizadorVideoUrlScreen extends StatefulWidget {
  final String url;

  const VisualizadorVideoUrlScreen({required this.url, super.key});

  @override
  State<VisualizadorVideoUrlScreen> createState() =>
      _VisualizadorVideoUrlScreenState();
}

class _VisualizadorVideoUrlScreenState
    extends State<VisualizadorVideoUrlScreen> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) return;
        _controller
          ..setLooping(true)
          ..play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatarDuracao(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _alternarReproducao() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
  }

  Widget _conteudo() {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        return Column(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _alternarReproducao,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: value.aspectRatio,
                        child: VideoPlayer(_controller),
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
                      onPressed: _alternarReproducao,
                      icon: Icon(
                        value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: VideoProgressIndicator(
                        _controller,
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
      body: _conteudo(),
    );
  }
}
