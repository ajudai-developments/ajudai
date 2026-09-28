import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum TipoTela { mobile, tablet, desktop }

class Breakpoints {
  static const double tablet = 700;
  static const double desktop = 1100;

  static TipoTela of(double largura) {
    if (largura >= desktop) return TipoTela.desktop;
    if (largura >= tablet) return TipoTela.tablet;
    return TipoTela.mobile;
  }
}

extension ResponsivoContext on BuildContext {
  TipoTela get tipoTela => Breakpoints.of(MediaQuery.sizeOf(this).width);

  bool get ehMobile => tipoTela == TipoTela.mobile;
  bool get ehTablet => tipoTela == TipoTela.tablet;
  bool get ehDesktop => tipoTela == TipoTela.desktop;
  bool get ehLargo => tipoTela != TipoTela.mobile;

  /// Web E tela larga. App nativo e web estreita usam o layout mobile.
  bool get usaLayoutWeb => kIsWeb && !ehMobile;
}

class ConteudoCentralizado extends StatelessWidget {
  final Widget child;
  final double larguraMax;
  const ConteudoCentralizado({
    super.key,
    required this.child,
    this.larguraMax = 900,
  });

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: larguraMax),
      child: child,
    ),
  );
}
