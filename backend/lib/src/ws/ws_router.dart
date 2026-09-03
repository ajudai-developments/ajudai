import 'package:backend/src/handlers/admin_handler.dart';
import 'package:backend/src/handlers/agendamento_handler.dart';
import 'package:backend/src/handlers/endereco_handler.dart';
import 'package:backend/src/handlers/servico_handler.dart';
import 'package:backend/src/handlers/usuario_handler.dart';
import 'package:shared/shared.dart';
import '../handlers/auth_handler.dart';
import 'ws_connection.dart';

class WsRouter {
  final AuthHandler _authHandler;
  final UsuarioHandler _usuarioHandler;
  final EnderecoHandler _enderecoHandler;
  final AdminHandler _adminHandler;
  final AgendamentoHandler _agendamentoHandler;
  final ServicoHandler _servicoHandler;

  WsRouter(
    this._authHandler,
    this._usuarioHandler,
    this._enderecoHandler,
    this._adminHandler,
    this._agendamentoHandler,
    this._servicoHandler,
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

      case TipoMensagem.criarAgendamento:
        await _agendamentoHandler.handleCriarAgendamento(conexao, msg);

      case TipoMensagem.confirmarPagamento:
        await _agendamentoHandler.handleConfirmarPagamento(conexao, msg);

      case TipoMensagem.responderAgendamento:
        await _agendamentoHandler.handleResponderAgendamento(conexao, msg);

      case TipoMensagem.iniciarAgendamento:
        await _agendamentoHandler.handleIniciarAgendamento(conexao, msg);

      case TipoMensagem.concluirAgendamento:
        await _agendamentoHandler.handleConcluirAgendamento(conexao, msg);

      case TipoMensagem.confirmarConclusaoAgendamento:
        await _agendamentoHandler.handleConfirmarConclusaoAgendamento(
          conexao,
          msg,
        );

      case TipoMensagem.cancelarAgendamento:
        await _agendamentoHandler.handleCancelarAgendamento(conexao, msg);

      case TipoMensagem.obterAgendamento:
        await _agendamentoHandler.handleObterAgendamento(conexao, msg);

      case TipoMensagem.listarMeusAgendamentos:
        await _agendamentoHandler.handleListarMeusAgendamentos(conexao, msg);

      case TipoMensagem.listarAgendamentosRecebidos:
        await _agendamentoHandler.handleListarAgendamentosRecebidos(
          conexao,
          msg,
        );

      case TipoMensagem.criarServicoOferecido:
        await _servicoHandler.handleCriarServicoOferecido(conexao, msg);

      case TipoMensagem.listarMeusServicosOferecidos:
        await _servicoHandler.handleListarMeusServicosOferecidos(conexao, msg);

      case TipoMensagem.obterServicoOferecido:
        await _servicoHandler.handleObterServicoOferecido(conexao, msg);
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
