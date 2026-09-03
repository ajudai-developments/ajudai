import 'package:backend/src/services/agendamento_service.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';

class AgendamentoHandler {
  final AgendamentoService _agendamentoService;
  AgendamentoHandler(this._agendamentoService);

  Future<void> handleCriarAgendamento(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = CriarAgendamentoRequestDto.fromJson(msg);
      final resposta = await _agendamentoService.criarPreview(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ArgumentError catch (e) {
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.dadosInvalidos,
          mensagem: e.message.toString(),
        ),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao criar preview de agendamento: $e');
      print(stackTrace);
      try {
        conexao.enviar(
          ErroDto(codigo: ErroCodigo.erroInterno, mensagem: 'Erro interno'),
        );
      } catch (_) {}
    }
  }

  Future<void> handleConfirmarPagamento(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ConfirmarPagamentoRequestDto.fromJson(msg);
      final resposta = await _agendamentoService.confirmarPagamento(
        conexao,
        dto,
      );
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ArgumentError catch (e) {
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.dadosInvalidos,
          mensagem: e.message.toString(),
        ),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao confirmar pagamento: $e');
      print(stackTrace);
      try {
        conexao.enviar(
          ErroDto(codigo: ErroCodigo.erroInterno, mensagem: 'Erro interno'),
        );
      } catch (_) {}
    }
  }
}
