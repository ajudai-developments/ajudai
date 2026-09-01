import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../session/session_storage.dart';
import '../../../ws/ws_client.dart';
import '../../../ws/ws_client_provider.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final wsClient = ref.watch(wsClientProvider);
  return AuthRepository(wsClient);
});

final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => SessionStorage(),
);

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      repository: ref.watch(authRepositoryProvider),
      sessionStorage: ref.watch(sessionStorageProvider),
    );
  },
);

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SessionStorage _sessionStorage;

  AuthController({required this._repository, required this._sessionStorage})
    : super(const AuthInicial());

  Future<void> restaurarSessao() async {
    final usuario = await _sessionStorage.carregar();
    if (usuario != null) {
      state = AuthAutenticado(usuario);
    }
  }

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
    String? telefone,
  }) async {
    state = const AuthCarregando();
    try {
      final usuario = await _repository.cadastrar(
        nome: nome,
        email: email,
        senha: senha,
        cpf: cpf,
        telefone: telefone,
      );
      await _sessionStorage.salvar(usuario);
      state = AuthAutenticado(usuario);
      return true;
    } on WsErrorException catch (e) {
      state = AuthErro(e.mensagem);
      return false;
    } catch (e) {
      print(e);
      state = const AuthErro(
        'Não foi possível concluir o cadastro. Tente novamente.',
      );
      return false;
    }
  }

  Future<bool> login({required String email, required String senha}) async {
    state = const AuthCarregando();
    try {
      final usuario = await _repository.login(email: email, senha: senha);
      await _sessionStorage.salvar(usuario);
      state = AuthAutenticado(usuario);
      return true;
    } on WsErrorException catch (e) {
      state = AuthErro(e.mensagem);
      return false;
    } catch (_) {
      state = const AuthErro(
        'Não foi possível entrar. Verifique seus dados e tente novamente.',
      );
      return false;
    }
  }

  Future<void> sair() async {
    await _sessionStorage.limpar();
    state = const AuthInicial();
  }
}
