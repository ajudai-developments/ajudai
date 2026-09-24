import 'package:flutter/material.dart';

class VisualizadorImagemUrlScreen extends StatelessWidget {
  final String url;

  const VisualizadorImagemUrlScreen({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white70,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
