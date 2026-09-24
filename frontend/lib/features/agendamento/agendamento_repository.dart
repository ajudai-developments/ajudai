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
/// dois métodos pedem os mesmos parâmetros (prestadorId,
/// servicoOferecidoId, enderecoId, horaInicio, horaFim) — o backend
/// passou a exigir `prestadorId` explícito nos dois, não só
/// `servicoOferecidoId`.
///
/// Nota sobre "cliente" vs "prestador": `obterAgendamento` e
/// `listarMeusAgendamentos`/`listarAgendamentosRecebidos` não existem
/// mais como chamadas genéricas — o backend agora tem endpoints
/// separados pra cada papel (`*Cliente`/`*Prestador`), retornando
/// `AgendamentoDetalhadoCliente`/`AgendamentoDetalhadoPrestador` — que
/// já vêm com o nome da contraparte (`prestadorNome`/`clienteNome`)
/// embutido, sem precisar de chamada extra pra isso.
///
/// Nota sobre validação de horário: este repositório NÃO valida
/// horaInicio/horaFim com AgendamentoValidator (do shared) — isso é
/// responsabilidade da tela de criação. Os DateTimes que chegam aqui
/// devem estar em UTC (`.toUtc()` já aplicado por quem chama).
class AgendamentoRepository {
  Future<CriarAgendamentoResponseDto> criarAgendamento({
    required String prestadorId,
    required String servicoOferecidoId,
    required String enderecoId,
    required DateTime horaInicio,
    required DateTime horaFim,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      CriarAgendamentoRequestDto(
        prestadorId: prestadorId,
        servicoOferecidoId: servicoOferecidoId,
        enderecoId: enderecoId,
        horaInicio: horaInicio,
        horaFim: horaFim,
      ),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.criarAgendamentoOk,
    );
    return CriarAgendamentoResponseDto.fromJson(json);
  }

  Future<Agendamento> confirmarPagamento({
    required String prestadorId,
    required String servicoOferecidoId,
    required String enderecoId,
    required DateTime horaInicio,
    required DateTime horaFim,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      ConfirmarPagamentoRequestDto(
        prestadorId: prestadorId,
        servicoOferecidoId: servicoOferecidoId,
        enderecoId: enderecoId,
        horaInicio: horaInicio,
        horaFim: horaFim,
      ),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.confirmarPagamentoOk,
    );
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

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.responderAgendamentoOk,
    );
    return ResponderAgendamentoResponseDto.fromJson(json).agendamento;
  }

  Future<Agendamento> iniciarAgendamento(String agendamentoId) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      IniciarAgendamentoRequestDto(agendamentoId: agendamentoId),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.iniciarAgendamentoOk,
    );
    return IniciarAgendamentoResponseDto.fromJson(json).agendamento;
  }

  Future<Agendamento> concluirAgendamento(String agendamentoId) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      ConcluirAgendamentoRequestDto(agendamentoId: agendamentoId),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.concluirAgendamentoOk,
    );
    return ConcluirAgendamentoResponseDto.fromJson(json).agendamento;
  }

  Future<Agendamento> confirmarConclusaoAgendamento(
    String agendamentoId,
  ) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      ConfirmarConclusaoAgendamentoRequestDto(agendamentoId: agendamentoId),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.confirmarConclusaoAgendamentoOk,
    );
    return ConfirmarConclusaoAgendamentoResponseDto.fromJson(json).agendamento;
  }

  Future<Agendamento> cancelarAgendamento({
    required String agendamentoId,
    required String motivo,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      CancelarAgendamentoRequestDto(
        agendamentoId: agendamentoId,
        motivo: motivo,
      ),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.cancelarAgendamentoOk,
    );
    return CancelarAgendamentoResponseDto.fromJson(json).agendamento;
  }

  /// Detalhe de UM agendamento, visto pelo CLIENTE (quem pediu).

  /// Agendamentos que EU pedi (como cliente). Já vem com `prestadorNome`.
  Future<List<AgendamentoDetalhadoCliente>> listarAgendamentosCliente() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(ListarAgendamentosClienteRequestDto());

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.listarAgendamentosClienteOk,
    );
    return ListarAgendamentosClienteResponseDto.fromJson(json).agendamentos;
  }

  /// Agendamentos que EU recebi (como prestador). Já vem com `clienteNome`.
  Future<List<AgendamentoDetalhadoPrestador>>
  listarAgendamentosPrestador() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(ListarAgendamentosPrestadorRequestDto());

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.listarAgendamentosPrestadorOk,
    );
    return ListarAgendamentosPrestadorResponseDto.fromJson(json).agendamentos;
  }
}
