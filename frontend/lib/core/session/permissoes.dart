import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

enum Capacidade {
  criarAgendamento,
  confirmarPagamento,
  contestarAgendamento,
  avaliarAgendamento,
  denunciarUsuario,
  painelAdmin,
}

class Permissoes {
  final UserRole? papel;
  final bool isWeb;

  const Permissoes({required this.papel, this.isWeb = kIsWeb});

  bool pode(Capacidade c) {
    switch (c) {
      case Capacidade.criarAgendamento:
      case Capacidade.confirmarPagamento:
        return !isWeb;

      case Capacidade.painelAdmin:
        return papel == UserRole.admin;

      default:
        return true;
    }
  }
}
