import 'package:backend/src/handlers/admin_handler.dart';
import 'package:backend/src/handlers/endereco_handler.dart';
import 'package:backend/src/handlers/usuario_handler.dart';
import 'package:shared/shared.dart';
import '../handlers/auth_handler.dart';
import 'ws_connection.dart';

class WsRouter {
  final AuthHandler _authHandler;
  final UsuarioHandler _usuarioHandler;
  final EnderecoHandler _enderecoHandler;
  final AdminHandler _adminHandler;
  WsRouter(
    this._authHandler,
    this._usuarioHandler,
    this._enderecoHandler,
    this._adminHandler,
  );

  Future<void> rotear(WsConnection conexao, Map<String, dynamic> msg) async {
    final tipo = TipoMensagem.fromValor(msg['tipo'] as String?);
    if (tipo == null) {
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.dadosInvalidos,
          mensagem: 'Tipo de mensagem desconhecido: ${msg['tipo']}',
        ),
      );
      return;
    }

    switch (tipo) {
      case TipoMensagem.login:
        await _authHandler.handleLogin(conexao, msg);
        break;
      case TipoMensagem.cadastro:
        await _authHandler.handleCadastro(conexao, msg);
        break;

      case TipoMensagem.atualizarPerfil:
        await _usuarioHandler.handleAtualizarPerfil(conexao, msg);

      case TipoMensagem.consultarCep:
        await _enderecoHandler.handleConsultarCep(conexao, msg);

      case TipoMensagem.criarEndereco:
        await _enderecoHandler.handleCriarEndereco(conexao, msg);

      case TipoMensagem.obterMeusEnderecos:
        await _enderecoHandler.handleObterEndereco(conexao);

      case TipoMensagem.editarEndereco:
        await _enderecoHandler.handleEditarEndereco(conexao, msg);

      case TipoMensagem.solicitarPrestador:
        await _usuarioHandler.solicitarSerPrestador(conexao, msg);

      case TipoMensagem.listarVerificacoes:
        await _adminHandler.handleListarVerificacoes(conexao, msg);

      case TipoMensagem.aprovarPrestador:
        await _adminHandler.handleAprovarPrestador(conexao, msg);

      case TipoMensagem.rejeitarPrestador:
        await _adminHandler.handleRejeitarPrestador(conexao, msg);
      default:
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.dadosInvalidos,
            mensagem: 'Tipo de mensagem não aceito como request: ${tipo.valor}',
          ),
        );
    }
  }
}
