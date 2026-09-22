import 'package:backend/src/services/notificacao_service.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

class NotificacaoHandler {
  final NotificacaoService _notificacaoService;

  NotificacaoHandler(this._notificacaoService);

  Future<void> handleListarNotificacoes(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final resposta = await _notificacaoService.listarNaoLidas(conexao);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on PostgrestException catch (e, stackTrace) {
      print('Erro ao listar notificações: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar notificações',
        ),
      );
    } catch (e, stackTrace) {
      print('Erro ao listar notificações: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar notificações',
        ),
      );
    }
  }

  Future<void> handleMarcarNotificacaoComoLida(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = MarcarNotificacaoComoLidaRequestDto.fromJson(msg);
      final resposta = await _notificacaoService.marcarComoLida(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on PostgrestException catch (e, stackTrace) {
      print('Erro ao marcar notificação como lida: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao marcar notificação como lida',
        ),
      );
    } catch (e, stackTrace) {
      print('Erro ao marcar notificação como lida: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao marcar notificação como lida',
        ),
      );
    }
  }

  Future<void> handleMarcarTodasNotificacoesComoLida(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      MarcarTodasNotificacoesComoLidaRequestDto.fromJson(msg);
      final resposta = await _notificacaoService.marcarTodasComoLidas(conexao);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on PostgrestException catch (e, stackTrace) {
      print('Erro ao marcar todas as notificações como lidas: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao marcar todas as notificações como lidas',
        ),
      );
    } catch (e, stackTrace) {
      print('Erro ao marcar todas as notificações como lidas: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao marcar todas as notificações como lidas',
        ),
      );
    }
  }
}
