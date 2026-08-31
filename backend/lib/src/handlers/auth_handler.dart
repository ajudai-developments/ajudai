import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';
import '../services/auth_service.dart';
import '../ws/ws_connection.dart';

class AuthHandler {
  final AuthService _authService;

  AuthHandler(this._authService);

  Future<void> handleLogin(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = LoginRequestDto.fromJson(msg);
      final resposta = await _authService.login(conexao, dto);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on AuthApiException {
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.credenciaisInvalidas,
          mensagem: "E-mail ou senha incorreto(s)",
        ),
      );
    } catch (e, stackTrace) {
      print("Um erro ocorreu: ${e.toString()}");
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: "Ocorreu um erro interno",
        ),
      );
    }
  }

  Future<void> handleCadastro(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = CadastroRequestDto.fromJson(msg);
      final resposta = await _authService.cadastrar(conexao, dto);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on AuthWeakPasswordException {
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.senhaFraca,
          mensagem:
              "A senha deve conter letras entre A e Z e conter ao menos 1 número!",
        ),
      );
    } on AuthApiException {
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.emailJaCadastrado,
          mensagem: "Este e-mail já está cadastrador no sistema!",
        ),
      );
    } on AuthException catch (e) {
      if (e.message.contains('Database error saving new user')) {
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.cpfJaCadastrado,
            mensagem: 'CPF já cadastrado',
          ),
        );
      } else {
        conexao.enviar(
          ErroDto(codigo: ErroCodigo.emailJaCadastrado, mensagem: e.message),
        );
      }
    } catch (e, stackTrace) {
      print("Erro inesperado: $e");
      print(stackTrace);
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.erroInterno, mensagem: e.toString()),
      );
    }
  }
}
