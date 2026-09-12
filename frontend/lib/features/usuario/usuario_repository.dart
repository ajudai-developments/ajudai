import 'package:shared/shared.dart';

import '../../core/session/sessao.dart';
import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

/// Repositório do perfil do PRÓPRIO usuário logado.
///
/// Login/cadastro já preenchem `Sessao.instance.usuario` — este
/// repositório só cuida de ATUALIZAR nome/telefone. Assim como
/// AuthRepository, atualiza a Sessao automaticamente após sucesso, pra
/// qualquer tela que leia `Sessao.instance.usuario` já ver o dado novo
/// sem precisar recarregar nada.
class UsuarioRepository {
  Future<Usuario> atualizarPerfil({String? nome, String? telefone}) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      AtualizarPerfilRequestDto(nome: nome, telefone: telefone),
    );

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.atualizarPerfilOk);
    final usuario = AtualizarPerfilResponseDto.fromJson(json).usuario;

    Sessao.instance.definirUsuario(usuario);
    return usuario;
  }
}