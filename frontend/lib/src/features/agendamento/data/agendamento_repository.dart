// lib/src/features/agendamento/data/agendamento_repository.dart
import 'package:shared/shared.dart';

import '../../../ws/ws_client.dart';

class AgendamentoRepository {
  final WsClient _wsClient;

  AgendamentoRepository(this._wsClient);

  // Buscar serviços oferecidos por um serviço específico (prestadores)
  Future<List<ServicoOferecidoPreview>> listarServicosOferecidos({
    required String servicoId,
    String? categoriaId,
  }) async {
    // TODO: Verificar se existe DTO específico para isso
    // Por enquanto vamos usar o que temos disponível
    // Se não tiver, podemos criar um DTO específico

    // Usando o mesmo DTO de listagem de serviços mas com filtro
    final request = ListarServicosRequestDto(categoriaId: categoriaId!);

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.listarServicosOk.valor},
    );

    final dto = ListarServicosResponseDto.fromJson(response);
    // Transformar em ServicoOferecidoPreview
    // Nota: Pode ser necessário ajustar dependendo do backend
    return dto.servicos.map((servico) {
      return ServicoOferecidoPreview(
        servicoOferecidoId: servico.servicoOferecidoId,
        servicoNome: servico.servicoNome,
        categoriaNome: '', // Preencher depois
        valor: 0.0, // Preencher depois
        prestadorId: '', // Preencher depois
        prestadorNome: 'Prestador', // Placeholder
        prestadorVerificado: false,
        mediaAvaliacao: null,
        quantidadeAvaliacoes: 0,
        quantidadeSelos: 0,
      );
    }).toList();
  }

  // Buscar detalhes de um serviço oferecido específico
  Future<ObterServicoOferecidoResponseDto> obterServicoOferecido(
    String servicoOferecidoId,
  ) async {
    final request = ObterServicoOferecidoRequestDto(
      servicoOferecidoId: servicoOferecidoId,
    );

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.obterServicoOferecidoOk.valor},
    );

    return ObterServicoOferecidoResponseDto.fromJson(response);
  }

  // Criar agendamento
  Future<CriarAgendamentoResponseDto> criarAgendamento({
    required String servicoOferecidoId,
    required String enderecoId,
    required DateTime horaInicio,
    required DateTime horaFim,
  }) async {
    // Validar horário antes de enviar
    final agoraUtc = DateTime.now().toUtc();
    AgendamentoValidator.validar(
      agoraUtc: agoraUtc,
      horaInicioUtc: horaInicio.toUtc(),
      horaFimUtc: horaFim.toUtc(),
    );

    final request = CriarAgendamentoRequestDto(
      servicoOferecidoId: servicoOferecidoId,
      enderecoId: enderecoId,
      horaInicio: horaInicio.toUtc(),
      horaFim: horaFim.toUtc(),
    );

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.criarAgendamentoOk.valor},
    );

    return CriarAgendamentoResponseDto.fromJson(response);
  }

  // Confirmar pagamento
  Future<ConfirmarPagamentoResponseDto> confirmarPagamento({
    required String servicoOferecidoId,
    required String enderecoId,
    required DateTime horaInicio,
    required DateTime horaFim,
  }) async {
    final request = ConfirmarPagamentoRequestDto(
      servicoOferecidoId: servicoOferecidoId,
      enderecoId: enderecoId,
      horaInicio: horaInicio.toUtc(),
      horaFim: horaFim.toUtc(),
    );

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.confirmarPagamentoOk.valor},
    );

    return ConfirmarPagamentoResponseDto.fromJson(response);
  }

  // Listar agendamentos do usuário
  Future<List<Agendamento>> listarMeusAgendamentos({
    List<String>? status,
  }) async {
    final request = ListarMeusAgendamentosRequestDto(status: status);

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.listarMeusAgendamentosOk.valor},
    );

    // O response contém uma lista de agendamentos
    // Precisamos parsear manualmente
    final agendamentosList = response['agendamentos'] as List;
    return agendamentosList
        .map((json) => Agendamento.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Obter detalhes de um agendamento específico
  Future<ObterAgendamentoResponseDto> obterAgendamento(
    String agendamentoId,
  ) async {
    final request = ObterAgendamentoRequestDto(agendamentoId: agendamentoId);

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.obterAgendamentoOk.valor},
    );

    return ObterAgendamentoResponseDto.fromJson(response);
  }

  // Responder agendamento (aceitar/recusar) - para prestadores
  Future<ResponderAgendamentoResponseDto> responderAgendamento({
    required String agendamentoId,
    required bool aceitar,
  }) async {
    final request = ResponderAgendamentoRequestDto(
      agendamentoId: agendamentoId,
      aceitar: aceitar,
    );

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.responderAgendamentoOk.valor},
    );

    return ResponderAgendamentoResponseDto.fromJson(response);
  }

  // Iniciar agendamento - para prestadores
  Future<IniciarAgendamentoResponseDto> iniciarAgendamento(
    String agendamentoId,
  ) async {
    final request = IniciarAgendamentoRequestDto(agendamentoId: agendamentoId);

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.iniciarAgendamentoOk.valor},
    );

    return IniciarAgendamentoResponseDto.fromJson(response);
  }

  // Concluir agendamento - para prestadores
  Future<ConcluirAgendamentoResponseDto> concluirAgendamento(
    String agendamentoId,
  ) async {
    final request = ConcluirAgendamentoRequestDto(agendamentoId: agendamentoId);

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.concluirAgendamentoOk.valor},
    );

    return ConcluirAgendamentoResponseDto.fromJson(response);
  }

  // Confirmar conclusão - para clientes
  Future<ConfirmarConclusaoAgendamentoResponseDto> confirmarConclusao(
    String agendamentoId,
  ) async {
    final request = ConfirmarConclusaoAgendamentoRequestDto(
      agendamentoId: agendamentoId,
    );

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.confirmarConclusaoAgendamentoOk.valor},
    );

    return ConfirmarConclusaoAgendamentoResponseDto.fromJson(response);
  }

  // Cancelar agendamento
  Future<CancelarAgendamentoResponseDto> cancelarAgendamento({
    required String agendamentoId,
    required String motivo,
  }) async {
    final request = CancelarAgendamentoRequestDto(
      agendamentoId: agendamentoId,
      motivo: motivo,
    );

    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.cancelarAgendamentoOk.valor},
    );

    return CancelarAgendamentoResponseDto.fromJson(response);
  }
}
