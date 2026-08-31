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
}
