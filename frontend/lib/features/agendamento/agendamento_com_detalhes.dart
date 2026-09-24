import 'package:shared/shared.dart';

import '../servico/servico_repository.dart';

enum PapelAgendamento { cliente, prestador }

class AgendamentoComDetalhes {
  final Agendamento agendamento;
  final PapelAgendamento papel;
  final String nomeContraparte;
  final String? contraparteAvatarUrl;
  final bool contraparteVerificada;
  final String nomeServico;

  const AgendamentoComDetalhes({
    required this.agendamento,
    required this.papel,
    required this.nomeContraparte,
    required this.contraparteAvatarUrl,
    required this.contraparteVerificada,
    required this.nomeServico,
  });

  bool get comoCliente => papel == PapelAgendamento.cliente;
  bool get comoPrestador => papel == PapelAgendamento.prestador;

  factory AgendamentoComDetalhes.doCliente(
    AgendamentoDetalhadoCliente d,
    String nomeServico,
  ) => AgendamentoComDetalhes(
    agendamento: d.agendamento,
    papel: PapelAgendamento.cliente,
    nomeContraparte: d.prestadorNome,
    contraparteAvatarUrl: d.prestadorAvatarUrl,
    contraparteVerificada: d.prestadorVerificado,
    nomeServico: nomeServico,
  );

  factory AgendamentoComDetalhes.doPrestador(
    AgendamentoDetalhadoPrestador d,
    String nomeServico,
  ) => AgendamentoComDetalhes(
    agendamento: d.agendamento,
    papel: PapelAgendamento.prestador,
    nomeContraparte: d.clienteNome,
    contraparteAvatarUrl: d.clienteAvatarUrl,
    contraparteVerificada: d.clienteVerificado,
    nomeServico: nomeServico,
  );

  /// Depois de uma ação (aceitar, cancelar...) só o Agendamento muda.
  AgendamentoComDetalhes copyWith({Agendamento? agendamento}) =>
      AgendamentoComDetalhes(
        agendamento: agendamento ?? this.agendamento,
        papel: papel,
        nomeContraparte: nomeContraparte,
        contraparteAvatarUrl: contraparteAvatarUrl,
        contraparteVerificada: contraparteVerificada,
        nomeServico: nomeServico,
      );
} // <-- a classe fecha AQUI

/// Resolve o nome do serviço pra uma lista de agendamentos do CLIENTE.
Future<List<AgendamentoComDetalhes>> carregarComDetalhesCliente(
  List<AgendamentoDetalhadoCliente> itens,
  ServicoRepository repo,
) => _resolverNomeServico(
  itens: itens,
  servicoOferecidoIdDe: (i) => i.agendamento.servicoOferecidoId,
  montar: AgendamentoComDetalhes.doCliente,
  servicoRepository: repo,
);

/// Resolve o nome do serviço pra uma lista de agendamentos do PRESTADOR.
Future<List<AgendamentoComDetalhes>> carregarComDetalhesPrestador(
  List<AgendamentoDetalhadoPrestador> itens,
  ServicoRepository repo,
) => _resolverNomeServico(
  itens: itens,
  servicoOferecidoIdDe: (i) => i.agendamento.servicoOferecidoId,
  montar: AgendamentoComDetalhes.doPrestador,
  servicoRepository: repo,
);

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
  required String Function(T) servicoOferecidoIdDe,
  required AgendamentoComDetalhes Function(T, String nomeServico) montar,
  required ServicoRepository servicoRepository,
}) async {
  final cache = <String, String>{};
  final resultado = <AgendamentoComDetalhes>[];

  for (final item in itens) {
    final id = servicoOferecidoIdDe(item);
    var nome = cache[id];
    if (nome == null) {
      try {
        final detalhe = await servicoRepository.obterServicoOferecido(
          servicoOferecidoId: id,
        );
        nome = detalhe.servico.nome;
        cache[id] = nome;
      } catch (_) {
        nome = 'Serviço indisponível';
      }
    }
    resultado.add(montar(item, nome));
  }
  return resultado;
}
