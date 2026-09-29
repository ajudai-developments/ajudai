import 'package:shared/shared.dart';

import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

/// Repositório de ações administrativas (verificações de prestador,
/// contestações e denúncias) — usado somente pelas telas do painel admin.
class AdminRepository {
  // ---------------------------------------------------------------------------
  // Verificações
  // ---------------------------------------------------------------------------

  Future<List<VerificacaoComUrls>> listarVerificacoes(
    StatusVerificacao? status,
  ) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(ListarVerificacoesRequestDto(status: status));

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.listarVerificacoesOk,
    );
    return ListarVerificacoesResponseDto.fromJson(json).verificacoes;
  }

  Future<AprovarPrestadorResponseDto> aprovarPrestador(
    String verificacaoId,
  ) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      AprovarPrestadorRequestDto(verificacaoId: verificacaoId),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.aprovarPrestadorOk,
    );
    return AprovarPrestadorResponseDto.fromJson(json);
  }

  Future<RejeitarPrestadorResponseDto> rejeitarPrestador({
    required String verificacaoId,
    required String motivo,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      RejeitarPrestadorRequestDto(verificacaoId: verificacaoId, motivo: motivo),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.rejeitarPrestadorOk,
    );
    return RejeitarPrestadorResponseDto.fromJson(json);
  }

  // ---------------------------------------------------------------------------
  // Contestações
  // ---------------------------------------------------------------------------

  Future<List<ContestacaoComUrls>> listarContestacoes(
    StatusContestacao? status,
  ) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(AdminListarContestacoesRequestDto(status: status));

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.adminListarContestacoesOk,
    );
    return AdminListarContestacoesResponseDto.fromJson(json).contestacoes;
  }

  /// Marca a contestação como "em análise" (só tem efeito se estiver aberta).
  /// Devolve o status atual no servidor.
  Future<StatusContestacao> marcarContestacaoEmAnalise(
    String contestacaoId,
  ) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      AdminMarcarContestacaoEmAnaliseRequestDto(contestacaoId: contestacaoId),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.adminMarcarContestacaoEmAnaliseOk,
    );
    return AdminMarcarContestacaoEmAnaliseResponseDto.fromJson(json).status;
  }

  Future<Contestacao> responderContestacao({
    required String contestacaoId,
    required StatusContestacao status,
    required String resposta,
    required StatusAgendamento statusAgendamentoFinal,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      AdminResponderContestacaoRequestDto(
        contestacaoId: contestacaoId,
        status: status,
        resposta: resposta,
        statusAgendamentoFinal: statusAgendamentoFinal,
      ),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.adminResponderContestacaoOk,
    );
    return AdminResponderContestacaoResponseDto.fromJson(json).contestacao;
  }

  // ---------------------------------------------------------------------------
  // Denúncias
  // ---------------------------------------------------------------------------

  Future<List<DenunciaAdminComUrls>> listarDenuncias(
    StatusDenuncia? status,
  ) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(AdminListarDenunciasRequestDto(status: status));

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.adminListarDenunciasOk,
    );
    return AdminListarDenunciasResponseDto.fromJson(json).denuncias;
  }

  /// Marca a denúncia como "em análise" (só tem efeito se estiver aberta).
  /// Devolve o status atual no servidor.
  Future<StatusDenuncia> marcarDenunciaEmAnalise(String denunciaId) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      AdminMarcarDenunciaEmAnaliseRequestDto(denunciaId: denunciaId),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.adminMarcarDenunciaEmAnaliseOk,
    );
    return AdminMarcarDenunciaEmAnaliseResponseDto.fromJson(json).status;
  }

  Future<Denuncia> responderDenuncia({
    required String denunciaId,
    required StatusDenuncia status,
    required String resposta,
    required bool removerPrestador,
    required bool banirUsuario,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      AdminResponderDenunciaRequestDto(
        denunciaId: denunciaId,
        status: status,
        resposta: resposta,
        removerPrestador: removerPrestador,
        banirUsuario: banirUsuario,
      ),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.adminResponderDenunciaOk,
    );
    return AdminResponderDenunciaResponseDto.fromJson(json).denuncia;
  }
}
