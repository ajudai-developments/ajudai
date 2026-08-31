import 'package:backend/src/repositories/usuario_repository.dart';
import 'package:shared/shared.dart';
import 'sessao_service.dart';
import '../ws/ws_connection.dart';

class UsuarioService {
  final SessaoService _sessaoService;

  UsuarioService(this._sessaoService);

  Future<AtualizarPerfilResponseDto> atualizarPerfil(
    WsConnection conexao,
    AtualizarPerfilRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    if (client == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    if (dto.telefone == null && dto.nome == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: "Atualize ao menos algum campo!",
      );
    }

    if (dto.telefone != null && !TelefoneValidator.isValido(dto.telefone!)) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Telefone inválido',
      );
    }

    final telefoneLimpo = dto.telefone != null
        ? TelefoneValidator.limpar(dto.telefone!)
        : null;

    final usuarioRepository = UsuarioRepository(client);
    final usuario = await usuarioRepository.atualizarPerfil(
      nome: dto.nome,
      telefone: telefoneLimpo,
    );

    return AtualizarPerfilResponseDto(usuario: usuario);
  }
}
