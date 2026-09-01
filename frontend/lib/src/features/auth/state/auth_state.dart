import 'package:shared/shared.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInicial extends AuthState {
  const AuthInicial();
}

class AuthCarregando extends AuthState {
  const AuthCarregando();
}

class AuthAutenticado extends AuthState {
  final Usuario usuario;
  const AuthAutenticado(this.usuario);
}

class AuthErro extends AuthState {
  final String mensagem;
  const AuthErro(this.mensagem);
}
