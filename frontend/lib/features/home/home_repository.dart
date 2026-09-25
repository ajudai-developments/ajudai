import 'package:shared/shared.dart';

import '../../core/session/sessao.dart';
import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

/// Repositório da Home.
///
/// Categorias de serviço NÃO ficam aqui — usar ServicoRepository
/// (features/servico/servico_repository.dart), que é a fonte única de
/// verdade pra isso e também é usado pela categorias_screen.
///
/// NÃO implementar ainda, pois o backend não suporta:
/// - "serviços recentes" (não existe endpoint/tabela para isso);
/// - busca por serviço/prestador (sem filtro implementado);
/// - serviços próximos por localização (sem geolocalização mapeada).
class HomeRepository {
  /// Agendamento mais próximo em que o usuário logado é o CLIENTE
  /// (ele contratou um prestador). `null` se não houver nenhum dentro
  /// da janela considerada "próxima" pelo backend, ou se não houver
  /// usuário logado.
  Future<AgendamentoDetalhadoCliente?> buscarAgendamentoProximoCliente() async {
    if (!Sessao.instance.estaLogado) return null;

    await WsClient.instance.conectar();
    WsClient.instance.enviar(BuscarAgendamentoProximoClienteRequestDto());

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.buscarAgendamentoProximoClienteOk,
    );
    return BuscarAgendamentoProximoClienteResponseDto.fromJson(
      json,
    ).agendamento;
  }

  /// Agendamento mais próximo em que o usuário logado é o PRESTADOR
  /// (um cliente agendou com ele). Só faz sentido chamar quando
  /// `Sessao.instance.ehPrestador` for `true`.
  Future<AgendamentoDetalhadoPrestador?>
  buscarAgendamentoProximoPrestador() async {
    if (!Sessao.instance.estaLogado) return null;

    await WsClient.instance.conectar();
    WsClient.instance.enviar(BuscarAgendamentoProximoPrestadorRequestDto());

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.buscarAgendamentoProximoPrestadorOk,
    );
    return BuscarAgendamentoProximoPrestadorResponseDto.fromJson(
      json,
    ).agendamento;
  }

  // TODO: Future<List<ServicoOferecidoPreview>> obterServicosRecentes()
  //   — aguardando endpoint no backend.

  // TODO: Future<List<ServicoOferecidoPreview>> buscarServicosProximos()
  //   — aguardando geolocalização + endpoint no backend.
}
