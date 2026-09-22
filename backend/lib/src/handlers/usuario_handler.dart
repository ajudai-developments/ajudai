import 'package:shared/shared.dart';
import '../services/usuario_service.dart';
import '../ws/ws_connection.dart';

class UsuarioHandler {
  final UsuarioService _usuarioService;

  UsuarioHandler(this._usuarioService);

  Future<void> handleAtualizarPerfil(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = AtualizarPerfilRequestDto.fromJson(msg);
      final resposta = await _usuarioService.atualizarPerfil(conexao, dto);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.erroInterno, mensagem: e.toString()),
      );
    }
  }

  Future<void> solicitarSerPrestador(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = SolicitarPrestadorRequestDto.fromJson(msg);
      final resposta = await _usuarioService.serPrestador(conexao, dto);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.erroInterno, mensagem: e.toString()),
      );
    }
  }

  Future<void> obterPerfilPublico(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ObterPerfilPublicoRequestDto.fromJson(msg);
      final resposta = await _usuarioService.obterPerfilPublico(conexao, dto);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.erroInterno, mensagem: e.toString()),
      );
    }
  }

  Future<void> handleObterPerfilCompleto(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final resposta = await _usuarioService.obterPerfilCompleto(conexao);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.erroInterno, mensagem: e.toString()),
      );
    }
  }

  Future<void> handleAtualizarAvatar(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = AtualizarAvatarRequestDto.fromJson(msg);
      final resposta = await _usuarioService.atualizarAvatar(conexao, dto);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.erroInterno, mensagem: e.toString()),
      );
    }
  }
}
