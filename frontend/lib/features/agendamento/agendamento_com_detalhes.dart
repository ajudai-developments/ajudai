import 'package:shared/shared.dart';

import '../servico/servico_repository.dart';

/// Agendamento acompanhado do nome do serviço e, quando visto pelo
/// cliente, do nome do prestador.
///
/// O modelo `Agendamento` só tem IDs (servicoOferecidoId, prestadorId,
/// usuarioId), sem nome legível. `nomeServico`/`nomePrestador` são
/// resolvidos via ServicoRepository.obterServicoOferecido — isso dá o
/// nome do PRESTADOR, então só faz sentido exibir quando quem está
/// olhando é o cliente (`comoCliente: true`).
///
/// Quando é o prestador vendo seus agendamentos recebidos, o "outro
/// lado" é o cliente (usuarioId) — e não existe endpoint pra obter nome
/// de usuário a partir de um id ainda. Nesse caso `nomePrestador` fica
/// `null` de propósito, e a UI deve mostrar um placeholder genérico
/// ("Cliente") em vez de tentar exibir um nome que não temos.
class AgendamentoComDetalhes {
  final Agendamento agendamento;
  final String nomeServico;
  final String? nomePrestador;

  AgendamentoComDetalhes({
    required this.agendamento,
    required this.nomeServico,
    required this.nomePrestador,
  });
}

/// Resolve nome do serviço (e, se `comoCliente`, do prestador) pra uma
/// lista de agendamentos.
///
/// IMPORTANTE: as chamadas a `obterServicoOferecido` são feitas EM
/// SEQUÊNCIA (await dentro do for), nunca em paralelo — o protocolo
/// atual não tem id de correlação nas mensagens (ver a limitação
/// documentada em WsMessageStream.aguardar), então disparar várias
/// chamadas do mesmo tipo ao mesmo tempo faria a primeira resposta que
/// chegasse resolver qualquer uma das pendentes, misturando os dados
/// entre agendamentos diferentes. Isso deixa o carregamento mais lento
/// (uma ida e volta por serviço distinto, um de cada vez) em troca de
/// corretude.
///
/// Um cache local evita repetir a chamada quando vários agendamentos
/// apontam pro mesmo servicoOferecidoId.
///
/// Se a busca de um serviço específico falhar (ex: foi removido), esse
/// item entra com nome de fallback em vez de quebrar a lista inteira.
Future<List<AgendamentoComDetalhes>> carregarAgendamentosComDetalhes(
  List<Agendamento> agendamentos,
  ServicoRepository servicoRepository, {
  required bool comoCliente,
}) async {
  final cache = <String, ObterServicoOferecidoResponseDto>{};
  final resultado = <AgendamentoComDetalhes>[];

  for (final agendamento in agendamentos) {
    final id = agendamento.servicoOferecidoId;

    var detalhe = cache[id];
    if (detalhe == null) {
      try {
        detalhe = await servicoRepository.obterServicoOferecido(
          servicoOferecidoId: id,
        );
        cache[id] = detalhe;
      } catch (_) {
        resultado.add(
          AgendamentoComDetalhes(
            agendamento: agendamento,
            nomeServico: 'Serviço indisponível',
            nomePrestador: comoCliente ? 'Prestador indisponível' : null,
          ),
        );
        continue;
      }
    }

    resultado.add(
      AgendamentoComDetalhes(
        agendamento: agendamento,
        nomeServico: detalhe.servico.nome,
        nomePrestador: comoCliente ? detalhe.prestador.nome : null,
      ),
    );
  }

  return resultado;
}