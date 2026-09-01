import 'package:shared/shared.dart';
import '../services/endereco_service.dart';
import '../ws/ws_connection.dart';

class EnderecoHandler {
  final EnderecoService _enderecoService;

  EnderecoHandler(this._enderecoService);

  Future<void> handleConsultarCep(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ConsultarCepRequestDto.fromJson(msg);
      final resposta = await _enderecoService.consultarCep(dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao consultar CEP: $e');
      print(stackTrace);
      try {
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.erroInterno,
            mensagem: 'Erro ao consultar CEP',
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> handleCriarEndereco(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = CriarEnderecoRequestDto.fromJson(msg);
      final resposta = await _enderecoService.criarEndereco(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao criar endereço: $e');
      print(stackTrace);
      try {
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.erroInterno,
            mensagem: 'Erro ao criar endereço',
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> handleObterEndereco(WsConnection conexao) async {
    try {
      final resposta = await _enderecoService.obterMeusEnderecos(conexao);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao criar endereço: $e');
      print(stackTrace);
      try {
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.erroInterno,
            mensagem: 'Erro ao buscar endereços salvos',
          ),
        );
      } catch (_) {}
    }
  }
}
