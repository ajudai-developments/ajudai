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

  Future<void> handleResponderAgendamento(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ResponderAgendamentoRequestDto.fromJson(msg);
      final resposta = await _agendamentoService.responder(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao responder agendamento: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao responder agendamento',
        ),
      );
    }
  }

  Future<void> handleIniciarAgendamento(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = IniciarAgendamentoRequestDto.fromJson(msg);
      final resposta = await _agendamentoService.iniciar(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao iniciar agendamento: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao iniciar agendamento',
        ),
      );
    }
  }

  Future<void> handleConcluirAgendamento(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ConcluirAgendamentoRequestDto.fromJson(msg);
      final resposta = await _agendamentoService.concluir(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao concluir agendamento: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao concluir agendamento',
        ),
      );
    }
  }

  Future<void> handleConfirmarConclusaoAgendamento(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ConfirmarConclusaoAgendamentoRequestDto.fromJson(msg);
      final resposta = await _agendamentoService.confirmarConclusao(
        conexao,
        dto,
      );
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao confirmar conclusão do agendamento: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao confirmar conclusão do agendamento',
        ),
      );
    }
  }

  Future<void> handleCancelarAgendamento(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = CancelarAgendamentoRequestDto.fromJson(msg);
      final resposta = await _agendamentoService.cancelar(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao cancelar agendamento: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao cancelar agendamento',
        ),
      );
    }
  }

  Future<void> handleObterAgendamento(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ObterAgendamentoRequestDto.fromJson(msg);
      final resposta = await _agendamentoService.obter(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao obter agendamento: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao obter agendamento',
        ),
      );
    }
  }

  Future<void> handleListarMeusAgendamentos(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ListarMeusAgendamentosRequestDto.fromJson(msg);
      final resposta = await _agendamentoService.listarMeus(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao listar meus agendamentos: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar meus agendamentos',
        ),
      );
    }
  }

  Future<void> handleListarAgendamentosRecebidos(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ListarAgendamentosRecebidosRequestDto.fromJson(msg);
      final resposta = await _agendamentoService.listarRecebidos(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao listar agendamentos recebidos: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar agendamentos recebidos',
        ),
      );
    }
  }
}
