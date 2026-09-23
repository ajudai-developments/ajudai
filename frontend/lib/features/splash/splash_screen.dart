import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_repository.dart';

/// Tela exibida na abertura do app, antes de qualquer outra tela.
///
/// Responsabilidades:
/// 1. Tocar a animação de abertura (assets/videos/animacao_ajudai.mp4).
/// 2. Em paralelo, tentar restaurar uma sessão anterior a partir do
///    refresh_token salvo no dispositivo (AuthRepository.restaurarSessao)
///    — se der certo, Sessao.instance já fica populada.
/// 3. Navegar pra Home quando o vídeo terminar — SEMPRE pra Home, com
///    ou sem sessão restaurada. Não fica esperando a checagem de sessão
///    além disso: ela deve ser bem mais rápida que a duração do vídeo.
///    Quem está deslogado só não consegue tocar em Agenda/Perfil (ver
///    LoginNecessarioDialog).
///
/// Se o vídeo falhar ao carregar (asset ausente, formato não suportado
/// no aparelho, etc.), navega pra Home imediatamente em vez de travar o
/// usuário numa tela em branco.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _controller;
  bool _navegou = false;

  @override
  void initState() {
    super.initState();

    AuthRepository().restaurarSessao();

    _controller = VideoPlayerController.asset(
      'assets/videos/animacao_ajudai.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(_verificarFim);
    _controller.setLooping(false);
    _controller.setVolume(0);

    _iniciarVideo();
  }

  Future<void> _iniciarVideo() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() {});
      await _controller.play();
    } catch (_) {
      _irParaHome();
    }
  }

  void _verificarFim() {
    final valor = _controller.value;

    if (!valor.isInitialized || _navegou) return;

    if (valor.isCompleted) {
      _irParaHome();
    }
  }

  void _irParaHome() {
    if (_navegou || !mounted) return;
    _navegou = true;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.removeListener(_verificarFim);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
