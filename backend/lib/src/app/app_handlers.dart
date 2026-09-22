import 'package:backend/src/handlers/admin_handler.dart';
import 'package:backend/src/handlers/agendamento_handler.dart';
import 'package:backend/src/handlers/auth_handler.dart';
import 'package:backend/src/handlers/avaliacao_handler.dart';
import 'package:backend/src/handlers/categorias_handler.dart';
import 'package:backend/src/handlers/chat_handler.dart';
import 'package:backend/src/handlers/denuncia_handler.dart';
import 'package:backend/src/handlers/endereco_handler.dart';
import 'package:backend/src/handlers/notificacao_handler.dart';
import 'package:backend/src/handlers/servico_handler.dart';
import 'package:backend/src/handlers/usuario_handler.dart';

class AppHandlers {
  final AuthHandler auth;
  final UsuarioHandler usuario;
  final EnderecoHandler endereco;
  final AdminHandler admin;
  final AgendamentoHandler agendamento;
  final ServicoHandler servico;
  final CategoriaHandler categoria;
  final NotificacaoHandler notificacao;
  final AvaliacaoHandler avaliacao;
  final ChatHandler chat;
  final DenunciaHandler denuncia;

  const AppHandlers({
    required this.auth,
    required this.usuario,
    required this.endereco,
    required this.admin,
    required this.agendamento,
    required this.servico,
    required this.categoria,
    required this.notificacao,
    required this.avaliacao,
    required this.chat,
    required this.denuncia,
  });
}
