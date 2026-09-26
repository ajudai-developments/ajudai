import 'package:backend/src/services/chat_service.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';

class ChatHandler {
  final ChatService _chatService;
  ChatHandler(this._chatService);

  Future<void> handleCriarConversa(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = CriarConversaRequestDto.fromJson(msg);
      final resposta = await _chatService.criarConversa(conexao, dto);
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

  Future<void> handleListarConversas(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final resposta = await _chatService.listarConversas(conexao);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.erroInterno, mensagem: e.toString()),
      );
    }
  }

  Future<void> handleListarMensagens(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ListarMensagensRequestDto.fromJson(msg);
      final resposta = await _chatService.listarMensagens(conexao, dto);
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

  Future<void> handleEnviarMensagem(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = EnviarMensagemRequestDto.fromJson(msg);
      final resposta = await _chatService.enviarMensagem(conexao, dto);
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

  Future<void> handleBuscarConversa(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = BuscarConversaRequestDto.fromJson(msg);
      final resposta = await _chatService.buscarConversa(conexao, dto);
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
