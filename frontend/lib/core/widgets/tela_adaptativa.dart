import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/theme/app_colors.dart';
import 'package:ajudai/core/widgets/shell_web.dart';
import 'package:flutter/material.dart';

class TelaAdaptativa extends StatelessWidget {
  final String titulo;
  final String rotaAtual;
  final Widget child;
  final List<Widget> acoes;
  final Widget? rodapeMobile;

  /// AppBar própria para o layout mobile (ex: estilo das telas de edição).
  final PreferredSizeWidget? appBarMobile;

  /// Mobile sem AppBar (a tela desenha o próprio cabeçalho).
  final bool semAppBarMobile;
  final Widget? fabMobile;

  const TelaAdaptativa({
    super.key,
    required this.titulo,
    required this.rotaAtual,
    required this.child,
    this.acoes = const [],
    this.rodapeMobile,
    this.appBarMobile,
    this.semAppBarMobile = false,
    this.fabMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (context.usaLayoutWeb) {
      return ShellWeb(
        titulo: titulo,
        rotaAtual: rotaAtual,
        acoes: acoes,
        child: child,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: semAppBarMobile
          ? null
          : (appBarMobile ?? AppBar(title: Text(titulo), actions: acoes)),
      body: child,
      floatingActionButton: fabMobile,
      bottomNavigationBar: rodapeMobile,
    );
  }
}
