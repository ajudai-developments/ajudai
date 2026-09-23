import 'package:backend/src/app/app_handlers.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';

typedef WsHandler =
    Future<void> Function(WsConnection conexao, Map<String, dynamic> msg);

class WsRouter {
  final Map<TipoMensagem, WsHandler> _rotas;

  WsRouter(AppHandlers handlers) : _rotas = _criarRotas(handlers);

  static Map<TipoMensagem, WsHandler> _criarRotas(AppHandlers h) {
    return {
      TipoMensagem.login: h.auth.handleLogin,
      TipoMensagem.cadastro: h.auth.handleCadastro,
      TipoMensagem.restaurarSessao: h.auth.handleRestaurarSessao,

      TipoMensagem.atualizarPerfil: h.usuario.handleAtualizarPerfil,

      TipoMensagem.consultarCep: h.endereco.handleConsultarCep,

      TipoMensagem.criarEndereco: h.endereco.handleCriarEndereco,

      TipoMensagem.obterMeusEnderecos: (conexao, msg) =>
          h.endereco.handleObterMeusEndereco(conexao),

      TipoMensagem.editarEndereco: h.endereco.handleEditarEndereco,

      TipoMensagem.solicitarPrestador: h.usuario.solicitarSerPrestador,

      TipoMensagem.listarVerificacoes: h.admin.handleListarVerificacoes,

      TipoMensagem.aprovarPrestador: h.admin.handleAprovarPrestador,

      TipoMensagem.rejeitarPrestador: h.admin.handleRejeitarPrestador,

      TipoMensagem.criarAgendamento: h.agendamento.handleCriarAgendamento,

      TipoMensagem.confirmarPagamento: h.agendamento.handleConfirmarPagamento,

      TipoMensagem.responderAgendamento:
          h.agendamento.handleResponderAgendamento,

      TipoMensagem.iniciarAgendamento: h.agendamento.handleIniciarAgendamento,

      TipoMensagem.concluirAgendamento: h.agendamento.handleConcluirAgendamento,

      TipoMensagem.confirmarConclusaoAgendamento:
          h.agendamento.handleConfirmarConclusaoAgendamento,

      TipoMensagem.cancelarAgendamento: h.agendamento.handleCancelarAgendamento,

      TipoMensagem.obterAgendamentoCliente:
          h.agendamento.handleObterAgendamentoCliente,

      TipoMensagem.obterAgendamentoPrestador:
          h.agendamento.handleObterAgendamentoPrestador,

      TipoMensagem.listarAgendamentosCliente:
          h.agendamento.handleListarAgendamentosCliente,

      TipoMensagem.listarAgendamentosPrestador:
          h.agendamento.handleListarAgendamentosPrestador,

      TipoMensagem.listarNotificacoes: h.notificacao.handleListarNotificacoes,

      TipoMensagem.marcarNotificacaoComoLida:
          h.notificacao.handleMarcarNotificacaoComoLida,

      TipoMensagem.marcarTodasNotificacoesComoLida:
          h.notificacao.handleMarcarTodasNotificacoesComoLida,

      TipoMensagem.criarServicoOferecido: h.servico.handleCriarServicoOferecido,

      TipoMensagem.listarMeusServicosOferecidos:
          h.servico.handleListarMeusServicosOferecidos,

      TipoMensagem.listarMeusServicosOferecidosDesativados:
          h.servico.handleListarMeusServicosOferecidosDesativados,

      TipoMensagem.obterServicoOferecido: h.servico.handleObterServicoOferecido,

      TipoMensagem.listarCategorias: h.categoria.handleListarCategorias,

      TipoMensagem.listarServicoOferecidoPorCategoria:
          h.servico.handlerListarServicosOferecidosPorCategoria,

      TipoMensagem.listarServicoOferecidoPorServico:
          h.servico.handlerListarServicosOferecidosPorServico,

      TipoMensagem.listarServicos: h.servico.handlerListarServicos,

      TipoMensagem.avaliarAgendamento: h.avaliacao.handleAvaliarAgendamento,

      TipoMensagem.avaliarUsuario: h.avaliacao.handleAvaliarUsuario,

      TipoMensagem.editarServicoOferecido:
          h.servico.handleEditarServicoOferecido,

      TipoMensagem.desativarServicoOferecido:
          h.servico.handleDesativarServicoOferecido,

      TipoMensagem.obterPerfilPublico: h.usuario.obterPerfilPublico,

      TipoMensagem.obterPerfilCompleto: h.usuario.handleObterPerfilCompleto,

      TipoMensagem.atualizarAvatar: h.usuario.handleAtualizarAvatar,

      TipoMensagem.criarConversa: h.chat.handleCriarConversa,

      TipoMensagem.listarConversas: h.chat.handleListarConversas,

      TipoMensagem.listarMensagens: h.chat.handleListarMensagens,

      TipoMensagem.enviarMensagem: h.chat.handleEnviarMensagem,

      TipoMensagem.criarDenuncia: h.denuncia.handleCriarDenuncia,

      TipoMensagem.listarMinhasDenuncias:
          h.denuncia.handleListarMinhasDenuncias,

      TipoMensagem.criarContestacao: h.contestacao.handleCriarContestacao,

      TipoMensagem.listarMinhasContestacoes:
          h.contestacao.handleListarMinhasContestacoes,
    };
  }

  Future<void> rotear(WsConnection conexao, Map<String, dynamic> msg) async {
    final tipo = TipoMensagem.fromValor(msg['tipo'] as String?);

    if (tipo == null) {
      _enviarErro(conexao, 'Tipo de mensagem desconhecido: ${msg['tipo']}');
      return;
    }

    final handler = _rotas[tipo];

    if (handler == null) {
      _enviarErro(
        conexao,
        'Tipo de mensagem não aceito como request: ${tipo.valor}',
      );
      return;
    }

    await handler(conexao, msg);
  }

  void _enviarErro(WsConnection conexao, String mensagem) {
    conexao.enviar(
      ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: mensagem),
    );
  }
}
