import 'package:flutter/material.dart';

/// Overlay de carregamento simples, para sobrepor uma tela enquanto
/// uma chamada ao WsClient está em andamento.
class LoadingOverlay extends StatelessWidget {
  final bool visivel;
  final Widget child;

  const LoadingOverlay({super.key, required this.visivel, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (visivel)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}