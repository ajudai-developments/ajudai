import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoMensagem extends StatefulWidget {
  final String url;

  const VideoMensagem({required this.url, super.key});

  @override
  State<VideoMensagem> createState() => _VideoMensagemState();
}

class _VideoMensagemState extends State<VideoMensagem> {
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

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const SizedBox(
        width: 260,
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 260,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          if (!_controller.value.isPlaying)
            const CircleAvatar(
              backgroundColor: Color(0xAA000000),
              child: Icon(Icons.play_arrow, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
