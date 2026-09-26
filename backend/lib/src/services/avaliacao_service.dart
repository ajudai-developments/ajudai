import 'package:backend/src/repositories/agendamento_repository.dart';
import 'package:backend/src/repositories/avaliacao_repository.dart';
import 'package:backend/src/services/sessao_service.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';

const _janelaAvaliacao = Duration(hours: 24);

const _statusAvaliaveis = {
  StatusAgendamento.concluido,
  StatusAgendamento.cancelado,
  StatusAgendamento.contestado,
};

class AvaliacaoService {
  final SessaoService _sessaoService;

  AvaliacaoService(this._sessaoService);

  Future<Agendamento> _validarEObter(
    WsConnection conexao,
    String agendamentoId,
    String userId,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    if (client == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final agendamento = await AgendamentoRepository(
      client,
    ).buscarPorId(agendamentoId);
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
    if (agendamento.prestadorId == userId) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não pode avaliar seu próprio serviço',
      );
    }

    if (!_statusAvaliaveis.contains(agendamento.status)) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Esse agendamento não está em um status avaliável',
      );
    }

    final now = DateTime.now().toUtc();
    if (!now.isAfter(agendamento.horaInicio)) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Esse agendamento ainda não começou',
      );
    }

    final prazo = agendamento.horaInicio.add(_janelaAvaliacao);
    if (now.isAfter(prazo)) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'O prazo de 24 horas para avaliar esse agendamento expirou',
      );
    }

    return agendamento;
  }

  Future<AvaliarAgendamentoResponseDto> avaliarAgendamento(
    WsConnection conexao,
    AvaliarAgendamentoRequestDto dto,
  ) async {
    final userId = _sessaoService.userIdDe(conexao);
    final client = _sessaoService.clientDe(conexao);

    if (userId == null || client == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }
    if (!dto.pulado && dto.avaliacao == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Informe uma nota ou marque como pulado',
      );
    }

    final agendamento = await _validarEObter(
      conexao,
      dto.agendamentoId,
      userId,
    );
    final avaliadoId = userId == agendamento.usuarioId
        ? agendamento.prestadorId
        : agendamento.usuarioId;

    try {
      await AvaliacaoRepository(client).criarAvaliacaoAgendamento(
        agendamentoId: dto.agendamentoId,
        avaliadorId: userId,
        avaliadoId: avaliadoId,
        avaliacao: dto.pulado ? null : dto.avaliacao,
        pulada: dto.pulado,
        descricao: dto.descricao,
        mensagem: dto.mensagem,
        denuncia: dto.tipoDenuncia,
      );
    } on ArgumentError catch (e) {
      throw ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message);
    }

    return AvaliarAgendamentoResponseDto();
  }

  Future<AvaliarUsuarioResponseDto> avaliarUsuario(
    WsConnection conexao,
    AvaliarUsuarioRequestDto dto,
  ) async {
    final userId = _sessaoService.userIdDe(conexao);
    if (userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }
    if (!dto.pulado && dto.avaliacao == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Informe uma nota ou marque como pulado',
      );
    }

    final agendamento = await _validarEObter(
      conexao,
      dto.agendamentoId,
      userId,
    );
    final avaliadoId = userId == agendamento.usuarioId
        ? agendamento.prestadorId
        : agendamento.usuarioId;

    final client = _sessaoService.clientDe(conexao)!;
    try {
      await AvaliacaoRepository(client).criarAvaliacaoUsuario(
        agendamentoId: dto.agendamentoId,
        avaliadorId: userId,
        avaliadoId: avaliadoId,
        avaliacao: dto.pulado ? null : dto.avaliacao,
        pulada: dto.pulado,
        descricao: dto.descricao,
        mensagem: dto.mensagem,
      );
    } on ArgumentError catch (e) {
      throw ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message);
    }

    return AvaliarUsuarioResponseDto();
  }
}
