import 'package:ajudai/core/routes/destino_pos_login.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../auth/auth_repository.dart';

/// Tela de abertura. Responsabilidades:
/// 1. Restaurar a sessão anterior (refresh_token salvo).
/// 2. Mobile: tocar a animação de abertura enquanto isso acontece.
///    Web: sem animação, só um indicador de carregamento.
/// 3. Decidir o destino quando tudo estiver pronto:
///    - admin (só web) -> painel de admin;
///    - qualquer outro (logado ou não) -> Home.
///
/// Se o vídeo falhar, segue direto pro destino em vez de travar.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _timeoutSessao = Duration(seconds: 8);

  VideoPlayerController? _controller;
  late final Future<void> _sessao;
  bool _navegou = false;

  @override
  void initState() {
    super.initState();
    _sessao = _restaurarSessao();

    if (kIsWeb) {
      _finalizar();
    } else {
      _iniciarVideo();
    }
  }

  Future<void> _restaurarSessao() async {
    try {
      await AuthRepository().restaurarSessao().timeout(_timeoutSessao);
    } catch (_) {
      // Sem sessão / sem rede: segue deslogado.
    }
  }

  Future<void> _iniciarVideo() async {
    final controller = VideoPlayerController.asset(
      'assets/videos/animacao_ajudai.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = controller;

    controller
      ..addListener(_verificarFim)
      ..setLooping(false)
      ..setVolume(0);

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {});
      await controller.play();
    } catch (_) {
      _finalizar();
    }
  }

  void _verificarFim() {
    final valor = _controller?.value;
    if (valor == null || !valor.isInitialized || _navegou) return;
    if (valor.isCompleted) _finalizar();
  }

  /// Espera a sessão (se ainda não terminou) e navega.
  Future<void> _finalizar() async {
    if (_navegou) return;
    await _sessao;
    if (_navegou || !mounted) return;
    _navegou = true;
    Navigator.of(context).pushReplacementNamed(destinoPosLogin());
  }

  @override
  void dispose() {
    _controller?.removeListener(_verificarFim);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final videoPronto = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: kIsWeb
            ? const CircularProgressIndicator()
            : videoPronto
            ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
