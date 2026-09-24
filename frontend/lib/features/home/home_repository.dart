import 'package:shared/shared.dart';

import '../agendamento/agendamento_com_detalhes.dart';
import '../agendamento/agendamento_repository.dart';
import '../servico/servico_repository.dart';

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
///
/// Quando o backend ganhar esses recursos, cada um deve virar um método
/// aqui, seguindo o mesmo padrão de enviar um WsMessage e aguardar o
/// TipoMensagem de resposta correspondente.
class HomeRepository {
  final _agendamentoRepository = AgendamentoRepository();
  final _servicoRepository = ServicoRepository();

  Future<AgendamentoComDetalhes?> obterAgendamentoAtual() async {
    final itens = <AgendamentoComDetalhes>[];

    try {
      final agendamentosCliente = await _agendamentoRepository
          .listarAgendamentosCliente();
      itens.addAll(
        await carregarComDetalhesCliente(
          agendamentosCliente,
          _servicoRepository,
        ),
      );
    } catch (_) {}

    try {
      final agendamentosPrestador = await _agendamentoRepository
          .listarAgendamentosPrestador();
      itens.addAll(
        await carregarComDetalhesPrestador(
          agendamentosPrestador,
          _servicoRepository,
        ),
      );
    } catch (_) {}

    final atuais =
        itens
            .where(
              (item) =>
                  item.agendamento.status == StatusAgendamento.emAndamento,
            )
            .toList()
          ..sort(
            (a, b) =>
                a.agendamento.horaInicio.compareTo(b.agendamento.horaInicio),
          );

    if (atuais.isEmpty) return null;
    return atuais.first;
  }
}
