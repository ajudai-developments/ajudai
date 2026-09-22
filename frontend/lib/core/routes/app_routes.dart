/// Nomes de rota centralizados.
///
/// Este arquivo só define os NOMES das rotas (constantes) — não conhece
/// nenhuma tela, de propósito, pra não fazer `core/` depender de
/// `features/`. A tabela nome -> widget fica em `app.dart`, que é quem
/// tem legitimidade de conhecer todas as features.
class AppRoutes {
  AppRoutes._();

  // home
  static const String home = '/home';
  static const String splash = '/';

  // auth
  static const String login = '/login';
  static const String cadastro = '/cadastro';

  // usuario (perfil próprio, editável)
  static const String meuPerfil = '/perfil';
  static const String editarPerfil = '/perfil/editar';
  // "Ver mais" no meu perfil — média de avaliação, conquistas etc.
  // (obterPerfilCompleto não tem parâmetro, é sempre sobre o usuário logado).
  static const String meuPerfilCompleto = '/perfil/completo';

  // chat
  static const String conversas = '/conversas';

  // perfil publico (prestador ou cliente, somente leitura)
  static const String perfilPublico = '/perfil/publico';

  // endereco
  static const String meusEnderecos = '/enderecos';
  static const String formEndereco = '/enderecos/form';

  // servico
  static const String categorias = '/categorias';
  static const String servicosLista = '/servicos';
  static const String servicoDetalhe = '/servicos/detalhe';

  // prestador
  static const String solicitarPrestador = '/prestador/solicitar';
  static const String meusServicosOferecidos = '/prestador/meus-servicos';
  static const String formServicoOferecido = '/prestador/servico/form';

  // agendamento
  static const String criarAgendamento = '/agendamento/criar';
  static const String confirmarPagamento = '/agendamento/pagamento';
  static const String meusAgendamentos = '/agendamento/meus';
  static const String agendamentosRecebidos = '/agendamento/recebidos';
  static const String agendamentoDetalhe = '/agendamento/detalhe';

  // avaliacao
  static const String avaliarAgendamento = '/avaliacao/agendamento';
  static const String avaliarUsuario = '/avaliacao/usuario';

  // notificacao
  static const String notificacoes = '/notificacoes';

  // admin
  static const String verificacoes = '/admin/verificacoes';
  static const String verificacaoDetalhe = '/admin/verificacoes/detalhe';
}
