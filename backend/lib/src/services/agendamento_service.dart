import 'package:backend/src/models/endereco_resolvido.dart';
import 'package:backend/src/repositories/agendamento_repository.dart';
import 'package:backend/src/repositories/endereco_repository.dart';
import 'package:backend/src/repositories/servico_repository.dart';
import 'package:backend/src/services/pagamento_service.dart';
import 'package:backend/src/services/sessao_service.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

Future<EnderecoResolvido> _resolverEndereco(
  SupabaseClient client,
  String userId,
  String enderecoId,
) async {
  final endereco = await EnderecoRepository(client).buscarPorId(enderecoId);
  if (endereco == null || endereco.usuarioId != userId) {
    throw ErroDto(
      codigo: ErroCodigo.dadosInvalidos,
      mensagem: 'Endereço não encontrado',
    );
  }
  return EnderecoResolvido(
    id: endereco.id,
    logradouro: endereco.logradouro,
    numero: endereco.numero,
    complemento: endereco.complemento,
    bairro: endereco.bairro,
    cidade: endereco.cidade,
    estado: endereco.estado,
    cep: endereco.cep,
  );
}

class AgendamentoService {
  final SessaoService _sessaoService;
  final PagamentoService _pagamentoService;

  AgendamentoService(this._sessaoService, this._pagamentoService);

  Future<CriarAgendamentoResponseDto> criarPreview(
    WsConnection conexao,
    CriarAgendamentoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    AgendamentoValidator.validar(
      agoraUtc: DateTime.now().toUtc(),
      horaInicioUtc: dto.horaInicio,
      horaFimUtc: dto.horaFim,
    );

    final detalhe = await ServicoRepository(
      client,
    ).obterDetalheParaAgendamento(dto.servicoOferecidoId);
    if (detalhe == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Serviço não encontrado ou indisponível',
      );
    }

    final endereco = await _resolverEndereco(client, userId, dto.enderecoId);

    final conflito = await AgendamentoRepository(client).existeConflito(
      prestadorId: detalhe.prestadorId,
      horaInicio: dto.horaInicio,
      horaFim: dto.horaFim,
    );
    if (conflito) {
      throw ErroDto(
        codigo: ErroCodigo.conflitoHorario,
        mensagem: 'Esse horário não está mais disponível com esse prestador',
      );
    }

    return CriarAgendamentoResponseDto(
      servicoOferecidoId: detalhe.servicoOferecidoId,
      nomeServico: detalhe.servicoNome,
      nomePrestador: detalhe.prestadorNome,
      valor: detalhe.valor,
      horaInicio: dto.horaInicio,
      horaFim: dto.horaFim,
      enderecoResumo: endereco.resumo,
    );
  }

  Future<ConfirmarPagamentoResponseDto> confirmarPagamento(
    WsConnection conexao,
    ConfirmarPagamentoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    AgendamentoValidator.validar(
      agoraUtc: DateTime.now().toUtc(),
      horaInicioUtc: dto.horaInicio,
      horaFimUtc: dto.horaFim,
    );

    final detalhe = await ServicoRepository(
      client,
    ).obterDetalheParaAgendamento(dto.servicoOferecidoId);
    if (detalhe == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Serviço não encontrado ou indisponível',
      );
    }

    final endereco = await _resolverEndereco(client, userId, dto.enderecoId);

    final agendamentoRepository = AgendamentoRepository(client);

    final conflito = await agendamentoRepository.existeConflito(
      prestadorId: detalhe.prestadorId,
      horaInicio: dto.horaInicio,
      horaFim: dto.horaFim,
    );
    if (conflito) {
      throw ErroDto(
        codigo: ErroCodigo.conflitoHorario,
        mensagem: 'Esse horário não está mais disponível com esse prestador',
      );
    }

    final pagamentoAprovado = await _pagamentoService.processar(
      valor: detalhe.valor,
      metodoPagamento: dto.metodoPagamento,
    );

    if (!pagamentoAprovado) {
      throw ErroDto(
        codigo: ErroCodigo.pagamentoRecusado,
        mensagem: 'Pagamento não foi aprovado',
      );
    }

    final agendamento = await agendamentoRepository.criar(
      usuarioId: userId,
      prestadorId: detalhe.prestadorId,
      servicoOferecidoId: detalhe.servicoOferecidoId,
      endereco: endereco,
      horaInicio: dto.horaInicio,
      horaFim: dto.horaFim,
      valor: detalhe.valor,
    );

    _sessaoService.enviarParaUsuario(
      detalhe.prestadorId,
      NotificacaoDto(
        titulo: 'Novo agendamento',
        mensagem: '${detalhe.prestadorNome}, você recebeu um novo agendamento',
        dados: {'agendamentoId': agendamento.id},
      ),
    );

    return ConfirmarPagamentoResponseDto(agendamento: agendamento);
  }

  Future<ResponderAgendamentoResponseDto> responder(
    WsConnection conexao,
    ResponderAgendamentoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final prestadorId = _sessaoService.userIdDe(conexao);
    if (client == null || prestadorId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final repo = AgendamentoRepository(client);
    final agendamento = await repo.buscarPorId(dto.agendamentoId);
    if (agendamento == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Agendamento não encontrado',
      );
    }
    if (agendamento.prestadorId != prestadorId) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não está autorizado a fazer isso',
      );
    }
    if (agendamento.status != StatusAgendamento.pendente) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Esse agendamento já foi respondido',
      );
    }

    final novoStatus = dto.aceitar
        ? StatusAgendamento.aceito
        : StatusAgendamento.recusado;
    final atualizado = await repo.atualizarStatus(
      id: agendamento.id,
      status: novoStatus,
      alteradoPorUsuarioId: prestadorId,
    );

    _sessaoService.enviarParaUsuario(
      atualizado.usuarioId,
      NotificacaoDto(
        titulo: dto.aceitar ? 'Agendamento aceito' : 'Agendamento recusado',
        mensagem: dto.aceitar
            ? 'Seu prestador aceitou o agendamento'
            : 'Seu prestador recusou o agendamento',
        dados: {'agendamentoId': atualizado.id},
      ),
    );

    return ResponderAgendamentoResponseDto(agendamento: atualizado);
  }

  Future<IniciarAgendamentoResponseDto> iniciar(
    WsConnection conexao,
    IniciarAgendamentoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final prestadorId = _sessaoService.userIdDe(conexao);
    if (client == null || prestadorId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final repo = AgendamentoRepository(client);
    final agendamento = await repo.buscarPorId(dto.agendamentoId);
    if (agendamento == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Agendamento não encontrado',
      );
    }
    if (agendamento.prestadorId != prestadorId) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não está autorizado a fazer isso',
      );
    }
    if (agendamento.status != StatusAgendamento.aceito) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Esse agendamento não pode ser iniciado',
      );
    }

    final atualizado = await repo.atualizarStatus(
      id: agendamento.id,
      status: StatusAgendamento.emAndamento,
      alteradoPorUsuarioId: prestadorId,
    );

    _sessaoService.enviarParaUsuario(
      atualizado.usuarioId,
      NotificacaoDto(
        titulo: 'Atendimento iniciado',
        mensagem: 'Seu prestador iniciou o atendimento',
        dados: {'agendamentoId': atualizado.id},
      ),
    );
    return IniciarAgendamentoResponseDto(agendamento: atualizado);
  }

  Future<ConcluirAgendamentoResponseDto> concluir(
    WsConnection conexao,
    ConcluirAgendamentoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final prestadorId = _sessaoService.userIdDe(conexao);
    if (client == null || prestadorId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final repo = AgendamentoRepository(client);
    final agendamento = await repo.buscarPorId(dto.agendamentoId);
    if (agendamento == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Agendamento não encontrado',
      );
    }
    if (agendamento.prestadorId != prestadorId) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não está autorizado a fazer isso',
      );
    }
    if (agendamento.status != StatusAgendamento.emAndamento) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Esse agendamento não está em andamento',
      );
    }

    final atualizado = await repo.atualizarStatus(
      id: agendamento.id,
      status: StatusAgendamento.aguardandoConfirmacao,
      alteradoPorUsuarioId: prestadorId,
    );

    _sessaoService.enviarParaUsuario(
      atualizado.usuarioId,
      NotificacaoDto(
        titulo: 'Serviço concluído pelo prestador',
        mensagem: 'Confirme a conclusão do seu agendamento',
        dados: {'agendamentoId': atualizado.id},
      ),
    );

    return ConcluirAgendamentoResponseDto(agendamento: atualizado);
  }

  Future<ConfirmarConclusaoAgendamentoResponseDto> confirmarConclusao(
    WsConnection conexao,
    ConfirmarConclusaoAgendamentoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final repo = AgendamentoRepository(client);
    final agendamento = await repo.buscarPorId(dto.agendamentoId);
    if (agendamento == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Agendamento não encontrado',
      );
    }
    if (agendamento.usuarioId != userId) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não está autorizado a fazer isso',
      );
    }
    if (agendamento.status != StatusAgendamento.aguardandoConfirmacao) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Esse agendamento não está aguardando confirmação',
      );
    }

    final atualizado = await repo.atualizarStatus(
      id: agendamento.id,
      status: StatusAgendamento.concluido,
      alteradoPorUsuarioId: userId,
    );

    _sessaoService.enviarParaUsuario(
      atualizado.prestadorId,
      NotificacaoDto(
        titulo: 'Agendamento concluído',
        mensagem: 'O cliente confirmou a conclusão do agendamento',
        dados: {'agendamentoId': atualizado.id},
      ),
    );

    return ConfirmarConclusaoAgendamentoResponseDto(agendamento: atualizado);
  }

  Future<CancelarAgendamentoResponseDto> cancelar(
    WsConnection conexao,
    CancelarAgendamentoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final repo = AgendamentoRepository(client);
    final agendamento = await repo.buscarPorId(dto.agendamentoId);
    if (agendamento == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Agendamento não encontrado',
      );
    }
    if (agendamento.usuarioId != userId && agendamento.prestadorId != userId) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não está autorizado a fazer isso',
      );
    }
    if (![
      StatusAgendamento.pendente,
      StatusAgendamento.aceito,
    ].contains(agendamento.status)) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Esse agendamento não pode mais ser cancelado',
      );
    }

    final atualizado = await repo.atualizarStatus(
      id: agendamento.id,
      status: StatusAgendamento.cancelado,
      alteradoPorUsuarioId: userId,
    );

    final destinatario = userId == agendamento.usuarioId
        ? agendamento.prestadorId
        : agendamento.usuarioId;
    _sessaoService.enviarParaUsuario(
      destinatario,
      NotificacaoDto(
        titulo: 'Agendamento cancelado',
        mensagem: dto.motivo,
        dados: {'agendamentoId': atualizado.id},
      ),
    );

    return CancelarAgendamentoResponseDto(agendamento: atualizado);
  }

  Future<ObterAgendamentoResponseDto> obter(
    WsConnection conexao,
    ObterAgendamentoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final repo = AgendamentoRepository(client);
    final agendamento = await repo.buscarPorId(dto.agendamentoId);
    if (agendamento == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Agendamento não encontrado',
      );
    }
    if (agendamento.usuarioId != userId && agendamento.prestadorId != userId) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não está autorizado a fazer isso',
      );
    }

    return ObterAgendamentoResponseDto(agendamento: agendamento);
  }

  Future<ListarAgendamentosResponseDto> listarMeus(
    WsConnection conexao,
    ListarMeusAgendamentosRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final agendamentos = await AgendamentoRepository(
      client,
    ).listarPorUsuario(usuarioId: userId, status: dto.status);

    return ListarAgendamentosResponseDto(
      agendamentos: agendamentos,
      tipo: TipoMensagem.listarMeusAgendamentosOk,
    );
  }

  Future<ListarAgendamentosResponseDto> listarRecebidos(
    WsConnection conexao,
    ListarAgendamentosRecebidosRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final prestadorId = _sessaoService.userIdDe(conexao);
    if (client == null || prestadorId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final agendamentos = await AgendamentoRepository(
      client,
    ).listarPorPrestador(prestadorId: prestadorId, status: dto.status);

    return ListarAgendamentosResponseDto(
      agendamentos: agendamentos,
      tipo: TipoMensagem.listarAgendamentosRecebidosOk,
    );
  }
}
