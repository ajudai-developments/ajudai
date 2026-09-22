import 'package:backend/src/repositories/notificacao_repository.dart';
import 'package:backend/src/services/sessao_service.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';

class NotificacaoService {
  final SessaoService _sessaoService;
  final NotificacaoRepository _notificacaoRepository;

  const NotificacaoService(this._sessaoService, this._notificacaoRepository);

  Future<ListarMinhasNotificacoesResponseDto> listarNaoLidas(
    WsConnection conexao,
  ) async {
    final userId = _sessaoService.userIdDe(conexao);
    if (userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final notificacoes = await _notificacaoRepository.listarNaoLidas(userId);

    return ListarMinhasNotificacoesResponseDto(notificacoes: notificacoes);
  }

  Future<MarcarNotificacaoComoLidaResponseDto> marcarComoLida(
    WsConnection conexao,
    MarcarNotificacaoComoLidaRequestDto dto,
  ) async {
    final userId = _sessaoService.userIdDe(conexao);
    if (userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final marcada = await _notificacaoRepository.marcarComoLida(
      usuarioId: userId,
      notificacaoId: dto.notificacaoId,
    );
    if (!marcada) {
      throw ErroDto(
        codigo: ErroCodigo.naoEncontrado,
        mensagem: 'Notificação não encontrada',
      );
    }

    return const MarcarNotificacaoComoLidaResponseDto();
  }

  Future<MarcarTodasNotificacoesComoLidaResponseDto> marcarTodasComoLidas(
    WsConnection conexao,
  ) async {
    final userId = _sessaoService.userIdDe(conexao);
    if (userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    await _notificacaoRepository.marcarTodasComoLidas(userId);
    return const MarcarTodasNotificacoesComoLidaResponseDto();
  }
}
