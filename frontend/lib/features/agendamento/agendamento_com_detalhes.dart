import 'package:shared/shared.dart';

import '../servico/servico_repository.dart';

/// Um agendamento (visto pelo cliente OU pelo prestador) acompanhado do
/// nome do serviço.
///
/// `AgendamentoDetalhadoCliente`/`AgendamentoDetalhadoPrestador` já vêm
/// com o nome da CONTRAPARTE (prestadorNome/clienteNome) direto do
/// backend — não precisa mais resolver isso à parte (antes disso
/// existir, o prestador via "Cliente" como placeholder genérico; não é
/// mais o caso). O que nenhum dos dois carrega é o nome do SERVIÇO —
/// isso continua vindo via `obterServicoOferecido`.
class AgendamentoComDetalhes {
  final Agendamento agendamento;
  final String nomeContraparte;
  final String nomeServico;

  AgendamentoComDetalhes({
    required this.agendamento,
    required this.nomeContraparte,
    required this.nomeServico,
  });
}

/// Resolve o nome do serviço pra uma lista de agendamentos do CLIENTE.
Future<List<AgendamentoComDetalhes>> carregarComDetalhesCliente(
  List<AgendamentoDetalhadoCliente> agendamentos,
  ServicoRepository servicoRepository,
) {
  return _resolverNomeServico(
    itens: agendamentos,
    agendamentoDe: (item) => item.agendamento,
    nomeContraparteDe: (item) => item.prestadorNome,
    servicoRepository: servicoRepository,
  );
}

/// Resolve o nome do serviço pra uma lista de agendamentos do PRESTADOR.
Future<List<AgendamentoComDetalhes>> carregarComDetalhesPrestador(
  List<AgendamentoDetalhadoPrestador> agendamentos,
  ServicoRepository servicoRepository,
) {
  return _resolverNomeServico(
    itens: agendamentos,
    agendamentoDe: (item) => item.agendamento,
    nomeContraparteDe: (item) => item.clienteNome,
    servicoRepository: servicoRepository,
  );
}

/// IMPORTANTE: as chamadas a `obterServicoOferecido` são feitas EM
/// SEQUÊNCIA (await dentro do for), nunca em paralelo — o protocolo
/// atual não tem id de correlação nas mensagens (ver a limitação
/// documentada em WsMessageStream.aguardar), então disparar várias
/// chamadas do mesmo tipo ao mesmo tempo faria a primeira resposta que
/// chegasse resolver qualquer uma das pendentes, misturando os dados
/// entre agendamentos diferentes. Um cache local evita repetir a
/// chamada quando vários agendamentos apontam pro mesmo
/// servicoOferecidoId.
Future<List<AgendamentoComDetalhes>> _resolverNomeServico<T>({
  required List<T> itens,
  required Agendamento Function(T) agendamentoDe,
  required String Function(T) nomeContraparteDe,
  required ServicoRepository servicoRepository,
}) async {
  final cache = <String, String>{};
  final resultado = <AgendamentoComDetalhes>[];

  for (final item in itens) {
    final agendamento = agendamentoDe(item);
    final id = agendamento.servicoOferecidoId;

    var nomeServico = cache[id];
    if (nomeServico == null) {
      try {
        final detalhe = await servicoRepository.obterServicoOferecido(
          servicoOferecidoId: id,
        );
        nomeServico = detalhe.servico.nome;
        cache[id] = nomeServico;
      } catch (_) {
        nomeServico = 'Serviço indisponível';
      }
    }

    resultado.add(
      AgendamentoComDetalhes(
        agendamento: agendamento,
        nomeContraparte: nomeContraparteDe(item),
        nomeServico: nomeServico,
      ),
    );
  }

  return resultado;
}