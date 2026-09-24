import 'package:shared/shared.dart';

import '../../core/session/sessao.dart';
import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

/// Repositório do perfil do PRÓPRIO usuário logado.
///
/// Login/cadastro já preenchem `Sessao.instance.usuario` — este
/// repositório cuida de ATUALIZAR nome/telefone e de buscar o "perfil
/// completo" (média de avaliação, total de avaliações e conquistas/
/// selos), que não vem embutido no `Usuario` da sessão. Assim como
/// AuthRepository, `atualizarPerfil` atualiza a Sessao automaticamente
/// após sucesso, pra qualquer tela que leia `Sessao.instance.usuario`
/// já ver o dado novo sem precisar recarregar nada.
class UsuarioRepository {
  Future<Usuario> atualizarPerfil({String? nome, String? telefone}) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      AtualizarPerfilRequestDto(nome: nome, telefone: telefone),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.atualizarPerfilOk,
    );
    final usuario = AtualizarPerfilResponseDto.fromJson(json).usuario;

    Sessao.instance.definirUsuario(usuario);
    return usuario;
  }

  Future<Usuario> atualizarAvatar({
    required String imagemBase64,
    required String extensao,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      AtualizarAvatarRequestDto(imagemBase64: imagemBase64, extensao: extensao),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.atualizarAvatarOk,
    );
    final avatarUrl = AtualizarAvatarResponseDto.fromJson(json).avatarUrl;

    final usuarioAtual = Sessao.instance.usuario;
    if (usuarioAtual == null) {
      throw StateError('Sessão não encontrada.');
    }

    final usuarioAtualizado = usuarioAtual.copyWith(avatarUrl: avatarUrl);
    Sessao.instance.definirUsuario(usuarioAtualizado);
    return usuarioAtualizado;
  }

  Future<ObterPerfilPublicoResponseDto> obterPerfilPublico({
    required String usuarioId,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      ObterPerfilPublicoRequestDto(usuarioId: usuarioId),
    );

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.obterPerfilPublicoOk,
    );
    return ObterPerfilPublicoResponseDto.fromJson(json);
  }

  /// Média de avaliação, total de avaliações e conquistas (selos) do
  /// usuário logado. Usado em meu_perfil_screen.dart pra exibir os
  /// selos logo abaixo da foto de perfil.
  Future<PerfilCompleto> obterPerfilCompleto() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(PerfilCompletoRequestDto());

    final json = await WsMessageStream.instance.aguardar(
      TipoMensagem.obterPerfilCompletoOk,
    );
    return PerfilCompletoResponseDto.fromJson(json).perfil;
  }
}
