import 'package:backend/src/services/agendamento_service.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

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
    } on PostgrestException catch (e, strackTrace) {
      print('Erro ao criar preview de agendamento: $e');
      print(strackTrace);
      if (e.message.contains('22P02')) {
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.dadosInvalidos,
            mensagem: 'Endereço não encontrado',
          ),
        );
        return;
      }
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.erroInterno, mensagem: 'Erro interno'),
      );
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

  Future<void> handleListarAgendamentosCliente(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ListarAgendamentosClienteRequestDto.fromJson(msg);
      final resposta = await _agendamentoService.listarAgendamentosCliente(
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
      print('Erro ao listar meus agendamentos: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar os agendamentos',
        ),
      );
    }
  }

  Future<void> handleListarAgendamentosPrestador(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ListarAgendamentosPrestadorRequestDto.fromJson(msg);
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

  Future<void> handleListarHorariosOcupadosPrestador(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ListarHorarioOcupadoPrestadorRequestDto.fromJson(msg);
      final resposta = await _agendamentoService
          .listarHorariosOcupadosPrestador(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on PostgrestException catch (e, stackTrace) {
      if (e.code == "P0002") {
        conexao.enviar(
          ErroDto(codigo: ErroCodigo.naoEncontrado, mensagem: e.message),
        );
        return;
      } else if (e.code == "22P02") {
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.dadosInvalidos,
            mensagem: 'Prestador não encontrado',
          ),
        );
        return;
      }
      print('Erro ao listar horários ocupados: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar horários ocupados',
        ),
      );
    } catch (e, stackTrace) {
      print('Erro ao listar horários ocupados: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar horários ocupados',
        ),
      );
    }
  }

  Future<void> handleBuscarAgendamentoProximoCliente(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = BuscarAgendamentoProximoClienteRequestDto.fromJson(msg);
      final resposta = await _agendamentoService
          .buscarAgendamentoProximoCliente(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao buscar agendamento próximo do cliente: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao buscar agendamento próximo',
        ),
      );
    }
  }

  Future<void> handleBuscarAgendamentoProximoPrestador(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = BuscarAgendamentoProximoPrestadorRequestDto.fromJson(msg);
      final resposta = await _agendamentoService
          .buscarAgendamentoProximoPrestador(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao buscar agendamento próximo do prestador: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao buscar agendamento próximo',
        ),
      );
    }
  }

  Future<void> handleBuscarAgendamentoDetalhado(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = BuscarAgendamentoDetalhadoRequestDto.fromJson(msg);
      final resposta = await _agendamentoService.buscarAgendamentoDetalhado(
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
      print('Erro ao buscar agendamento detalhado: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao buscar detalhes do agendamento',
        ),
      );
    }
  }

  Future<void> handleListarHistoricoAgendamentosCliente(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ListarHistoricoAgendamentoClienteRequestDto.fromJson(msg);
      final resposta = await _agendamentoService
          .listarHistoricoAgendamentosCliente(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao listar histórico de agendamentos do cliente: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar histórico de agendamentos',
        ),
      );
    }
  }

  Future<void> handleListarHistoricoAgendamentosPrestador(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ListarHistoricoAgendamentoPrestadorRequestDto.fromJson(msg);
      final resposta = await _agendamentoService
          .listarHistoricoAgendamentosPrestador(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro ao listar histórico de agendamentos do prestador: $e');
      print(stackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao listar histórico de agendamentos',
        ),
      );
    }
  }
}
