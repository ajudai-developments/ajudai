import 'package:backend/src/handlers/admin_handler.dart';
import 'package:backend/src/handlers/agendamento_handler.dart';
import 'package:backend/src/handlers/avaliacao_handler.dart';
import 'package:backend/src/handlers/categorias_handler.dart';
import 'package:backend/src/handlers/chat_handler.dart';
import 'package:backend/src/handlers/endereco_handler.dart';
import 'package:backend/src/handlers/servico_handler.dart';
import 'package:backend/src/handlers/usuario_handler.dart';
import 'package:backend/src/handlers/notificacao_handler.dart';
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
  final CategoriaHandler _categoriaHandler;
  final NotificacaoHandler _notificacaoHandler;
  final AvaliacaoHandler _avaliacaoHandler;
  final ChatHandler _chatHandler;

  WsRouter(
    this._authHandler,
    this._usuarioHandler,
    this._enderecoHandler,
    this._adminHandler,
    this._agendamentoHandler,
    this._servicoHandler,
    this._categoriaHandler,
    this._notificacaoHandler,
    this._avaliacaoHandler,
    this._chatHandler,
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

      case TipoMensagem.restaurarSessao:
        await _authHandler.handleRestaurarSessao(conexao, msg);
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

      case TipoMensagem.obterAgendamentoCliente:
        await _agendamentoHandler.handleObterAgendamentoCliente(conexao, msg);

      case TipoMensagem.obterAgendamentoPrestador:
        await _agendamentoHandler.handleObterAgendamentoPrestador(conexao, msg);

      case TipoMensagem.listarAgendamentosCliente:
        await _agendamentoHandler.handleListarAgendamentosCliente(conexao, msg);

      case TipoMensagem.listarAgendamentosPrestador:
        await _agendamentoHandler.handleListarAgendamentosPrestador(
          conexao,
          msg,
        );

      case TipoMensagem.listarNotificacoes:
        await _notificacaoHandler.handleListarNotificacoes(conexao, msg);

      case TipoMensagem.marcarNotificacaoComoLida:
        await _notificacaoHandler.handleMarcarNotificacaoComoLida(conexao, msg);

      case TipoMensagem.marcarTodasNotificacoesComoLida:
        await _notificacaoHandler.handleMarcarTodasNotificacoesComoLida(
          conexao,
          msg,
        );

      case TipoMensagem.criarServicoOferecido:
        await _servicoHandler.handleCriarServicoOferecido(conexao, msg);

      case TipoMensagem.listarMeusServicosOferecidos:
        await _servicoHandler.handleListarMeusServicosOferecidos(conexao, msg);

      case TipoMensagem.listarMeusServicosOferecidosDesativados:
        await _servicoHandler.handleListarMeusServicosOferecidosDesativados(
          conexao,
          msg,
        );

      case TipoMensagem.obterServicoOferecido:
        await _servicoHandler.handleObterServicoOferecido(conexao, msg);

      case TipoMensagem.listarCategorias:
        await _categoriaHandler.handleListarCategorias(conexao, msg);

      case TipoMensagem.listarServicoOferecidoPorCategoria:
        await _servicoHandler.handlerListarServicosOferecidosPorCategoria(
          conexao,
          msg,
        );
      case TipoMensagem.listarServicoOferecidoPorServico:
        await _servicoHandler.handlerListarServicosOferecidosPorServico(
          conexao,
          msg,
        );

      case TipoMensagem.listarServicos:
        await _servicoHandler.handlerListarServicos(conexao, msg);

      case TipoMensagem.avaliarAgendamento:
        await _avaliacaoHandler.handleAvaliarAgendamento(conexao, msg);

      case TipoMensagem.avaliarUsuario:
        await _avaliacaoHandler.handleAvaliarUsuario(conexao, msg);

      case TipoMensagem.editarServicoOferecido:
        await _servicoHandler.handleEditarServicoOferecido(conexao, msg);

      case TipoMensagem.desativarServicoOferecido:
        await _servicoHandler.handleDesativarServicoOferecido(conexao, msg);

      case TipoMensagem.obterPerfilPublico:
        await _usuarioHandler.obterPerfilPublico(conexao, msg);

      case TipoMensagem.obterPerfilCompleto:
        await _usuarioHandler.handleObterPerfilCompleto(conexao, msg);

      case TipoMensagem.criarConversa:
        await _chatHandler.handleCriarConversa(conexao, msg);

      case TipoMensagem.listarConversas:
        await _chatHandler.handleListarConversas(conexao, msg);

      case TipoMensagem.listarMensagens:
        await _chatHandler.handleListarMensagens(conexao, msg);

      case TipoMensagem.enviarMensagem:
        await _chatHandler.handleEnviarMensagem(conexao, msg);

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
