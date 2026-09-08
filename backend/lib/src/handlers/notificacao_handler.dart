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
}
