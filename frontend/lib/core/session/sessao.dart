import 'package:ajudai/core/session/permissoes.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

/// Guarda o usuário autenticado na sessão atual do app.
///
/// Agora é um ChangeNotifier: quem depende da sessão (sidebar web,
/// bottom nav, etc.) pode escutar via ListenableBuilder/AnimatedBuilder
/// em vez de depender de rebuild por navegação — importante no layout
/// web, onde às vezes login/logout acontece sem trocar de tela.
class Sessao extends ChangeNotifier {
  Sessao._();
  static final Sessao instance = Sessao._();

  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  bool get estaLogado => _usuario != null;

  bool get ehPrestador => _usuario?.userRole == UserRole.prestador;

  bool get ehAdmin => _usuario?.userRole == UserRole.admin;
  Permissoes get permissoes => Permissoes(papel: usuario?.userRole);

  void definirUsuario(Usuario u) {
    _usuario = u;
    notifyListeners();
  }

  void limpar() {
    _usuario = null;
    notifyListeners();
  }
}
