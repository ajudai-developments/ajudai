import 'package:shared/shared.dart';
import 'package:backend/src/services/servico_service.dart';
import 'package:supabase/supabase.dart';
import '../ws/ws_connection.dart';

class ServicoHandler {
  final ServicoService _servicoService;

  ServicoHandler(this._servicoService);

  Future<void> handleCriarServicoOferecido(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = CriarServicoOferecidoRequestDto.fromJson(msg);
      final resposta = await _servicoService.criarOferecido(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on PostgrestException catch (e, stackTrace) {
      if (e.code == '23505') {
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.dadosInvalidos,
            mensagem: 'Você já oferece esse serviço',
          ),
        );
        return;
      }
      print('Erro ao criar serviço oferecido: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao criar serviço oferecido',
        ),
      );
    } catch (e, stackTrace) {
      print('Erro ao criar serviço oferecido: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao criar serviço oferecido',
        ),
      );
    }
  }

  Future<void> handleListarMeusServicosOferecidos(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final resposta = await _servicoService.listarMeus(conexao);
      conexao.enviar(resposta);
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao listar meus serviços oferecidos: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar meus serviços oferecidos',
        ),
      );
    }
  }

  Future<void> handleObterServicoOferecido(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ObterServicoOferecidoRequestDto.fromJson(msg);
      final resposta = await _servicoService.obterDetalhe(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao obter serviço oferecido: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao obter serviço oferecido',
        ),
      );
    }
  }

  Future<void> handlerListarServicosPorCategoria(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ListarServicosRequestDto.fromJson(msg);
      final resposta = await _servicoService.listarServicos(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao listar serviços por categoria: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar serviços por categoria',
        ),
      );
    }
  }
}
