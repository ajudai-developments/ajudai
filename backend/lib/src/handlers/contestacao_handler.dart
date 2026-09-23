import 'package:backend/src/services/contestacao_service.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';

class ContestacaoHandler {
  final ContestacaoService _servico;
  ContestacaoHandler(this._servico);

  Future<void> handleCriarContestacao(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = CriarContestacaoRequestDto.fromJson(msg);
      final resposta = await _servico.criarContestacao(conexao, dto);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.erroInterno, mensagem: e.toString()),
      );
    }
  }

  Future<void> handleListarMinhasContestacoes(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final resposta = await _servico.listarMinhasContestacoes(conexao);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.erroInterno, mensagem: e.toString()),
      );
    }
  }
}
