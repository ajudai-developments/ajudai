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

  Future<SolicitarPrestadorResponseDto> serPrestador(
    WsConnection conexao,
    SolicitarPrestadorRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final usuarioRepository = UsuarioRepository(client);
    final usuario = await usuarioRepository.buscarPorId(userId);
    if (usuario == null) {
      throw ErroDto(
        codigo: ErroCodigo.erroInterno,
        mensagem: 'Perfil não encontrado',
      );
    }

    if (usuario.statusPrestador == StatusPrestador.pendente) {
      throw ErroDto(
        codigo: ErroCodigo.solicitacaoEmAndamento,
        mensagem: 'Já existe uma solicitação feita em pendência!',
      );
    }
    if (usuario.statusPrestador == StatusPrestador.aprovado) {
      throw ErroDto(
        codigo: ErroCodigo.jaEUmPrestador,
        mensagem: 'Você já é um prestador na plataforma!',
      );
    }
    if (usuario.statusPrestador == StatusPrestador.suspenso) {
      throw ErroDto(
        codigo: ErroCodigo.suspensoComoPrestador,
        mensagem: 'Você está suspenso como prestador!',
      );
    }

    final verificacao = await usuarioRepository.solicitarSerPrestador(userId);
    return SolicitarPrestadorResponseDto(
      usuario: usuario,
      verificacao: verificacao,
    );
  }
}
