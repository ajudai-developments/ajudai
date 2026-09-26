import 'package:backend/src/models/endereco_resolvido.dart';
import 'package:backend/src/repositories/agendamento_repository.dart';
import 'package:backend/src/repositories/endereco_repository.dart';
import 'package:backend/src/repositories/servico_repository.dart';
import 'package:backend/src/repositories/usuario_repository.dart';
import 'package:backend/src/services/arquivo_upload_service.dart';
import 'package:backend/src/services/pagamento_service.dart';
import 'package:backend/src/services/sessao_service.dart';
import 'package:backend/src/supabase/supabase_client_factory.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

Future<EnderecoResolvido> _resolverEndereco(
  SupabaseClient client,
  String userId,
  String enderecoId,
) async {
  Endereco? endereco;

  endereco = await EnderecoRepository(client).buscarPorId(enderecoId);

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

    if (userId == dto.prestadorId) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: "Você não pode agendar um serviço consigo mesmo",
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

    if (userId == dto.prestadorId) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: "Você não pode agendar um serviço consigo mesmo",
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

    final agora = DateTime.now().toUtc();
    if (agendamento.horaInicio.isBefore(agora)) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Esse agendamento já passou do horário de início',
      );
    }

    if (agora.isAfter(
      agendamento.horaInicio.subtract(const Duration(minutes: 5)),
    )) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem:
            'Você só pode aceitar ou recusar o agendamento até 5 minutos antes do horário de início',
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
            ? 'Seu prestador aceitou o agendamento.'
            : 'Seu prestador recusou o agendamento. O valor de R\$${agendamento.valor} do agendamento será reembolsado.',
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

    final agora = DateTime.now().toUtc();
    final limiteAntecedencia = agendamento.horaInicio.subtract(
      const Duration(minutes: 5),
    );
    if (agora.isBefore(limiteAntecedencia)) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem:
            'Você só pode iniciar o atendimento a partir de 5 minutos antes do horário agendado',
      );
    }

    final atualizado = await repo.atualizarStatus(
      id: agendamento.id,
      status: StatusAgendamento.emAndamento,
      alteradoPorUsuarioId: prestadorId,
      camposExtras: {
        'hora_inicio_real': DateTime.now().toUtc().toIso8601String(),
      },
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

    if (agendamento.horaFim.isBefore(
      DateTime.now().toUtc().subtract(Duration(minutes: 5)),
    )) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem:
            'Você só pode concluir o atendimento até 5 minutos após o horário agendado',
      );
    }

    final atualizado = await repo.atualizarStatus(
      id: agendamento.id,
      status: StatusAgendamento.aguardandoConfirmacao,
      alteradoPorUsuarioId: prestadorId,
      camposExtras: {
        'hora_conclusao_prestador': DateTime.now().toUtc().toIso8601String(),
      },
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
      camposExtras: {
        'hora_confirmacao_usuario': DateTime.now().toUtc().toIso8601String(),
      },
    );

    _sessaoService.enviarParaUsuario(
      atualizado.usuarioId,
      NotificacaoDto(
        titulo: 'Avalie o serviço',
        mensagem: 'Você tem 15 minutos para avaliar o atendimento.',
        dados: {'agendamentoId': atualizado.id},
      ),
    );
    _sessaoService.enviarParaUsuario(
      atualizado.prestadorId,
      NotificacaoDto(
        titulo: 'Avalie o cliente',
        mensagem: 'Você tem 15 minutos para avaliar o cliente.',
        dados: {'agendamentoId': atualizado.id},
      ),
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

  Future<ListarAgendamentosClienteResponseDto> listarAgendamentosCliente(
    WsConnection conexao,
    ListarAgendamentosClienteRequestDto dto,
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
    ).listarAgendamentosCliente(usuarioId: userId);

    return ListarAgendamentosClienteResponseDto(agendamentos: agendamentos);
  }

  Future<ListarAgendamentosPrestadorResponseDto> listarRecebidos(
    WsConnection conexao,
    ListarAgendamentosPrestadorRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final prestadorId = _sessaoService.userIdDe(conexao);
    if (client == null || prestadorId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final usuario = await UsuarioRepository(
      SupabaseClientFactory.criarSecret(),
    ).buscarPorId(prestadorId);

    if (usuario == null) {
      throw ErroDto(
        codigo: ErroCodigo.usuarioInexistente,
        mensagem: 'usuário inválido',
      );
    }

    if (usuario.userRole != UserRole.prestador) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não é permitido para realizar esta ação.',
      );
    }

    final agendamentos = await AgendamentoRepository(
      client,
    ).listarAgendamentosPrestador(prestadorId: prestadorId);

    return ListarAgendamentosPrestadorResponseDto(agendamentos: agendamentos);
  }

  Future<ListarHorarioOcupadoPrestadorResponseDto>
  listarHorariosOcupadosPrestador(
    WsConnection conexao,
    ListarHorarioOcupadoPrestadorRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final horariosOcupados = await AgendamentoRepository(
      client,
    ).listarHorariosOcupadosPrestador(prestadorId: dto.prestadorId);

    return ListarHorarioOcupadoPrestadorResponseDto(
      horariosOcupados: horariosOcupados,
    );
  }

  Future<BuscarAgendamentoProximoPrestadorResponseDto>
  buscarAgendamentoProximoPrestador(
    WsConnection conexao,
    BuscarAgendamentoProximoPrestadorRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final prestadorId = _sessaoService.userIdDe(conexao);
    if (client == null || prestadorId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final usuario = await UsuarioRepository(
      SupabaseClientFactory.criarSecret(),
    ).buscarPorId(prestadorId);

    if (usuario == null) {
      throw ErroDto(
        codigo: ErroCodigo.usuarioInexistente,
        mensagem: 'usuário inválido',
      );
    }

    if (usuario.userRole != UserRole.prestador) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não é permitido para realizar esta ação.',
      );
    }

    final agendamento = await AgendamentoRepository(
      client,
    ).buscarAgendamentoProximoPrestador(prestadorId: prestadorId);

    return BuscarAgendamentoProximoPrestadorResponseDto(
      agendamento: agendamento,
    );
  }

  Future<BuscarAgendamentoProximoClienteResponseDto>
  buscarAgendamentoProximoCliente(
    WsConnection conexao,
    BuscarAgendamentoProximoClienteRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final agendamento = await AgendamentoRepository(
      client,
    ).buscarAgendamentoProximoCliente(usuarioId: userId);

    return BuscarAgendamentoProximoClienteResponseDto(agendamento: agendamento);
  }

  Future<BuscarAgendamentoDetalhadoResponseDto> buscarAgendamentoDetalhado(
    WsConnection conexao,
    BuscarAgendamentoDetalhadoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final agendamento = await AgendamentoRepository(client)
        .buscarAgendamentoDetalhado(
          agendamentoId: dto.agendamentoId,
          usuarioId: userId,
        );

    if (agendamento == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoEncontrado,
        mensagem: 'Agendamento não encontrado',
      );
    }

    ContestacaoComUrls? contestacaoComUrls;
    final contestacao = agendamento.contestacaoAberta;

    if (contestacao != null && contestacao.arquivos.isNotEmpty) {
      final urls = <String>[];
      for (final arquivo in contestacao.arquivos) {
        final url = await ArquivoUploadService.urlAssinada(
          client: client,
          bucket: 'contestamentos',
          prefixo: contestacao.id,
          arquivo: arquivo,
        );
        urls.add(url);
      }
      contestacaoComUrls = ContestacaoComUrls(
        contestacao: contestacao,
        urlsArquivos: urls,
      );
    }

    return BuscarAgendamentoDetalhadoResponseDto(
      agendamento: AgendamentoDetalhadoComUrls(
        agendamento: agendamento,
        contestacaoComUrls: contestacaoComUrls,
      ),
    );
  }

  Future<ListarHistoricoAgendamentoClienteResponseDto>
  listarHistoricoAgendamentosCliente(
    WsConnection conexao,
    ListarHistoricoAgendamentoClienteRequestDto dto,
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
    ).listarHistoricoAgendamentosCliente(usuarioId: userId);

    return ListarHistoricoAgendamentoClienteResponseDto(
      agendamentos: agendamentos,
    );
  }

  Future<ListarHistoricoAgendamentoPrestadorResponseDto>
  listarHistoricoAgendamentosPrestador(
    WsConnection conexao,
    ListarHistoricoAgendamentoPrestadorRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final prestadorId = _sessaoService.userIdDe(conexao);
    if (client == null || prestadorId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final usuario = await UsuarioRepository(
      SupabaseClientFactory.criarSecret(),
    ).buscarPorId(prestadorId);

    if (usuario == null) {
      throw ErroDto(
        codigo: ErroCodigo.usuarioInexistente,
        mensagem: 'usuário inválido',
      );
    }

    if (usuario.userRole != UserRole.prestador) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não é permitido para realizar esta ação.',
      );
    }

    final agendamentos = await AgendamentoRepository(
      client,
    ).listarHistoricoAgendamentosPrestador(usuarioId: prestadorId);

    return ListarHistoricoAgendamentoPrestadorResponseDto(
      agendamentos: agendamentos,
    );
  }
}
