import 'package:shared/shared.dart';

import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

/// Repositório de agendamentos.
///
/// Nota sobre o fluxo de criação: `criarAgendamento` NÃO cria o
/// agendamento de verdade — o backend só devolve um preview (nome do
/// serviço, do prestador, valor, resumo do endereço) pra confirmação.
/// Quem efetivamente cria o registro é `confirmarPagamento`, chamado
/// depois que o usuário revisa e confirma esse preview. Por isso os
/// dois métodos pedem os mesmos parâmetros (servicoOferecidoId,
/// enderecoId, horaInicio, horaFim).
///
/// Nota sobre validação de horário: este repositório NÃO valida
/// horaInicio/horaFim com AgendamentoValidator (do shared) — isso é
/// responsabilidade da tela de criação, do mesmo jeito que CPF/telefone
/// são validados em cadastro_screen antes de chegar no repositório.
class AgendamentoRepository {
  Future<CriarAgendamentoResponseDto> criarAgendamento({
    required String servicoOferecidoId,
    required String enderecoId,
    required DateTime horaInicio,
    required DateTime horaFim,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      CriarAgendamentoRequestDto(
        servicoOferecidoId: servicoOferecidoId,
        enderecoId: enderecoId,
        horaInicio: horaInicio,
        horaFim: horaFim,
      ),
    );

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.criarAgendamentoOk);
    return CriarAgendamentoResponseDto.fromJson(json);
  }

  Future<Agendamento> confirmarPagamento({
    required String servicoOferecidoId,
    required String enderecoId,
    required DateTime horaInicio,
    required DateTime horaFim,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      ConfirmarPagamentoRequestDto(
        servicoOferecidoId: servicoOferecidoId,
        enderecoId: enderecoId,
        horaInicio: horaInicio,
        horaFim: horaFim,
      ),
    );

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.confirmarPagamentoOk);
    return ConfirmarPagamentoResponseDto.fromJson(json).agendamento;
  }

  Future<Agendamento> responderAgendamento({
    required String agendamentoId,
    required bool aceitar,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      ResponderAgendamentoRequestDto(
        agendamentoId: agendamentoId,
        aceitar: aceitar,
      ),
    );

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.responderAgendamentoOk);
    return ResponderAgendamentoResponseDto.fromJson(json).agendamento;
  }

  Future<Agendamento> iniciarAgendamento(String agendamentoId) async {
    await WsClient.instance.conectar();

    WsClient.instance
        .enviar(IniciarAgendamentoRequestDto(agendamentoId: agendamentoId));

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.iniciarAgendamentoOk);
    return IniciarAgendamentoResponseDto.fromJson(json).agendamento;
  }

  Future<Agendamento> concluirAgendamento(String agendamentoId) async {
    await WsClient.instance.conectar();

    WsClient.instance
        .enviar(ConcluirAgendamentoRequestDto(agendamentoId: agendamentoId));

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.concluirAgendamentoOk);
    return ConcluirAgendamentoResponseDto.fromJson(json).agendamento;
  }

  Future<Agendamento> confirmarConclusaoAgendamento(String agendamentoId) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      ConfirmarConclusaoAgendamentoRequestDto(agendamentoId: agendamentoId),
    );

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.confirmarConclusaoAgendamentoOk);
    return ConfirmarConclusaoAgendamentoResponseDto.fromJson(json).agendamento;
  }

  Future<Agendamento> cancelarAgendamento({
    required String agendamentoId,
    required String motivo,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      CancelarAgendamentoRequestDto(agendamentoId: agendamentoId, motivo: motivo),
    );

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.cancelarAgendamentoOk);
    return CancelarAgendamentoResponseDto.fromJson(json).agendamento;
  }

  Future<Agendamento> obterAgendamento(String agendamentoId) async {
    await WsClient.instance.conectar();

    WsClient.instance
        .enviar(ObterAgendamentoRequestDto(agendamentoId: agendamentoId));

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.obterAgendamentoOk);
    return ObterAgendamentoResponseDto.fromJson(json).agendamento;
  }

  Future<List<Agendamento>> listarMeusAgendamentos() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(ListarMeusAgendamentosRequestDto());

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.listarMeusAgendamentosOk);
    return ListarAgendamentosResponseDto.fromJson(json).agendamentos;
  }

  Future<List<Agendamento>> listarAgendamentosRecebidos() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(ListarAgendamentosRecebidosRequestDto());

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.listarAgendamentosRecebidosOk);
    return ListarAgendamentosResponseDto.fromJson(json).agendamentos;
  }
}