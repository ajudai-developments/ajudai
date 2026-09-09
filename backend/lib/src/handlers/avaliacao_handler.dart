import 'package:backend/src/services/avaliacao_service.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';

class AvaliacaoHandler {
  final AvaliacaoService _avaliacaoService;
  AvaliacaoHandler(this._avaliacaoService);

  Future<void> handleAvaliarAgendamento(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = AvaliarAgendamentoRequestDto.fromJson(msg);
      final resposta = await _avaliacaoService.avaliarAgendamento(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao avaliar agendamento: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao avaliar agendamento',
        ),
      );
    }
  }

  Future<void> handleAvaliarUsuario(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = AvaliarUsuarioRequestDto.fromJson(msg);
      final resposta = await _avaliacaoService.avaliarUsuario(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao avaliar usuário: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao avaliar usuário',
        ),
      );
    }
  }
}
