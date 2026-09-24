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
  // TODO: Future<List<ServicoOferecidoPreview>> obterServicosRecentes()
  //   — aguardando endpoint no backend.

  // TODO: Future<List<ServicoOferecidoPreview>> buscarServicosProximos()
  //   — aguardando geolocalização + endpoint no backend.
}
