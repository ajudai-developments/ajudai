import 'package:shared/shared.dart';

import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

/// Repositório de avaliações pós-agendamento.
///
/// São duas avaliações distintas e independentes no backend:
/// - `avaliarAgendamento`: nota sobre o SERVIÇO/experiência em si.
/// - `avaliarUsuario`: nota sobre a PESSOA do outro lado (prestador ou
///   cliente — o backend decide o avaliado_id a partir de quem está
///   avaliando, não é um parâmetro que a gente passa).
///
/// A avaliação é OPCIONAL: quando [pulado] é true, [avaliacao] deve
/// vir nulo — o backend registra que a pessoa optou por não avaliar,
/// pra não voltar a oferecer essa opção depois.
///
/// Nenhuma das duas respostas (*Ok) carrega dados — só confirmam
/// sucesso, por isso os métodos retornam `void`.
class AvaliacaoRepository {
  Future<void> avaliarAgendamento({
    required String agendamentoId,
    required String avaliadoId,
    double? avaliacao,
    bool pulado = false,
    String? mensagem,
    String? descricao,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      AvaliarAgendamentoRequestDto(
        agendamentoId: agendamentoId,
        avaliacao: avaliacao,
        pulado: pulado,
        mensagem: mensagem,
        descricao: descricao,
      ),
    );

    await WsMessageStream.instance.aguardar(TipoMensagem.avaliarAgendamentoOk);
  }

  Future<void> avaliarUsuario({
    required String agendamentoId,
    double? avaliacao,
    bool pulado = false,
    String? mensagem,
    String? descricao,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      AvaliarUsuarioRequestDto(
        agendamentoId: agendamentoId,
        avaliacao: avaliacao,
        pulado: pulado,
        mensagem: mensagem,
        descricao: descricao,
      ),
    );

    await WsMessageStream.instance.aguardar(TipoMensagem.avaliarUsuarioOk);
  }
}
