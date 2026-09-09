import 'package:shared/shared.dart';

/// Guarda o usuário autenticado na sessão atual do app.
///
/// Usado pelas telas para decidir o que mostrar (ex: seção de prestador
/// só aparece se ehPrestador == true). Como o app usa setState simples
/// (sem gerenciador de estado), esta classe é só um "cofre" de leitura —
/// ela NÃO notifica ninguém quando muda. Uma tela que precise reagir a
/// login/logout deve navegar (push/pushReplacement) em vez de esperar
/// rebuild automático.
class Sessao {
  Sessao._();
  static final Sessao instance = Sessao._();

  Usuario? _usuario;

  /// Só leitura por fora — a única forma de mudar é via definirUsuario/limpar.
  Usuario? get usuario => _usuario;

  bool get estaLogado => _usuario != null;

  bool get ehPrestador => _usuario?.userRole == UserRole.prestador;

  bool get ehAdmin => _usuario?.userRole == UserRole.admin;

  void definirUsuario(Usuario u) => _usuario = u;

  void limpar() => _usuario = null;
}