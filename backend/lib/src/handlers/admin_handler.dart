import 'dart:convert';

import 'package:backend/src/services/admin_service.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';
import '../ws/ws_connection.dart';

class AdminHandler {
  final AdminService _adminService;

  AdminHandler(this._adminService);

  Future<void> handleListarVerificacoes(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = ListarVerificacoesRequestDto.fromJson(msg);
      final resposta = await _adminService.listarVerificacoes(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } catch (e, stackTrace) {
      print('Erro listar verificações: $e');
      print(stackTrace);
      try {
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.erroInterno,
            mensagem: 'Erro ao Listar verificações',
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> handleAprovarPrestador(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = AprovarPrestadorRequestDto.fromJson(msg);
      final resposta = await _adminService.aprovarPrestador(conexao, dto);
      conexao.enviar(resposta);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on JsonUnsupportedObjectError {
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.dadosInvalidos,
          mensagem:
              "Não foi possível aprovar o prestador. Os dados enviados estão inválidos.",
        ),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on PostgrestException catch (e, strackTrace) {
      if (e.code == "PGRST116") {
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.dadosInvalidos,
            mensagem: 'Verificação não encontrada',
          ),
        );
        return;
      }
      print('Erro ao aprovar prestador: $e');
      print(strackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao aprovar prestador',
        ),
      );
    } catch (e, stackTrace) {
      print('Erro ao aprovar prestador: $e');
      print(stackTrace);
      try {
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.erroInterno,
            mensagem: 'Erro ao aprovar prestador',
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> handleRejeitarPrestador(
    WsConnection conexao,
    Map<String, dynamic> msg,
  ) async {
    try {
      final dto = RejeitarPrestadorRequestDto.fromJson(msg);
      await _adminService.rejeitarPrestador(conexao, dto);
    } on FormatException catch (e) {
      conexao.enviar(
        ErroDto(codigo: ErroCodigo.dadosInvalidos, mensagem: e.message),
      );
    } on JsonUnsupportedObjectError {
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.dadosInvalidos,
          mensagem:
              "Não foi possível rejeitar o prestador. Os dados enviados estão inválidos.",
        ),
      );
    } on ErroDto catch (erro) {
      conexao.enviar(erro);
    } on PostgrestException catch (e, strackTrace) {
      if (e.code == "PGRST116") {
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.dadosInvalidos,
            mensagem: 'Verificação não encontrada',
          ),
        );
        return;
      }
      print('Erro ao rejeitar prestador: $e');
      print(strackTrace);
      conexao.enviar(
        ErroDto(
          codigo: ErroCodigo.erroInterno,
          mensagem: 'Erro ao rejeitar prestador',
        ),
      );
    } catch (e, stackTrace) {
      print('Erro ao rejeitar prestador: $e');
      print(stackTrace);
      try {
        conexao.enviar(
          ErroDto(
            codigo: ErroCodigo.erroInterno,
            mensagem: 'Erro ao rejeitar prestador',
          ),
        );
      } catch (_) {}
    }
  }
}
