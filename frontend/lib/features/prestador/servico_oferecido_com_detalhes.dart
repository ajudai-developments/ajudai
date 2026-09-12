import 'package:shared/shared.dart';

import '../servico/servico_repository.dart';

/// ServicoOferecido acompanhado do nome do serviço e da categoria.
///
/// O modelo `ServicoOferecido` só tem `servicoId` (não o nome), então
/// isso é resolvido via ServicoRepository.obterServicoOferecido — que
/// por coincidência é indexado pelo MESMO id que `ServicoOferecido.id`
/// (servicoOferecidoId), então dá pra reaproveitar direto.
class ServicoOferecidoComDetalhes {
  final ServicoOferecido servicoOferecido;
  final String nomeServico;
  final String nomeCategoria;

  ServicoOferecidoComDetalhes({
    required this.servicoOferecido,
    required this.nomeServico,
    required this.nomeCategoria,
  });
}

/// Resolve nome do serviço/categoria pra uma lista de serviços oferecidos.
///
/// Mesma limitação documentada em agendamento_com_detalhes.dart: as
/// chamadas são feitas EM SEQUÊNCIA (não em paralelo), porque o
/// protocolo não tem id de correlação — chamadas concorrentes do mesmo
/// tipo poderiam ter suas respostas trocadas entre si. Sem cache aqui
/// porque cada `servicoOferecido.id` já é único na lista (diferente do
/// caso de agendamentos, onde vários agendamentos podem repetir o
/// mesmo servicoOferecidoId).
Future<List<ServicoOferecidoComDetalhes>> carregarServicosOferecidosComDetalhes(
  List<ServicoOferecido> servicos,
  ServicoRepository servicoRepository,
) async {
  final resultado = <ServicoOferecidoComDetalhes>[];

  for (final servico in servicos) {
    try {
      final detalhe = await servicoRepository.obterServicoOferecido(
        servicoOferecidoId: servico.id,
      );
      resultado.add(
        ServicoOferecidoComDetalhes(
          servicoOferecido: servico,
          nomeServico: detalhe.servico.nome,
          nomeCategoria: detalhe.categoria.nome,
        ),
      );
    } catch (_) {
      resultado.add(
        ServicoOferecidoComDetalhes(
          servicoOferecido: servico,
          nomeServico: 'Serviço indisponível',
          nomeCategoria: '',
        ),
      );
    }
  }

  return resultado;
}