import 'package:flutter/material.dart';

/// Nomes de rota centralizados + onGenerateRoute.
///
/// Telas que precisam de parâmetro (ex: id do agendamento, id do usuário)
/// devem receber via `arguments` no Navigator.pushNamed.
class AppRoutes {
  AppRoutes._();

  // home
  static const String home = '/home';

  // auth
  static const String login = '/login';
  static const String cadastro = '/cadastro';

  // usuario (perfil próprio, editável)
  static const String meuPerfil = '/perfil';
  static const String editarPerfil = '/perfil/editar';

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

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // TODO: mapear cada rota acima para sua respectiva Screen,
      // extraindo `settings.arguments` quando necessário. Ex:
      //
      // case perfilPublico:
      //   final usuarioId = settings.arguments as String;
      //   return MaterialPageRoute(
      //     builder: (_) => PerfilPublicoScreen(usuarioId: usuarioId),
      //   );
      default:
        return null;
    }
  }
}
