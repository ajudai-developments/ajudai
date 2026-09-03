import 'package:backend/src/repositories/admin_repository.dart';
import 'package:backend/src/repositories/usuario_repository.dart';
import 'package:backend/src/supabase/supabase_client_factory.dart';
import 'package:shared/shared.dart';
import 'sessao_service.dart';
import '../ws/ws_connection.dart';

class AdminService {
  final SessaoService _sessaoService;

  AdminService(this._sessaoService);

  Future<ListarVerificacoesResponseDto> listarVerificacoes(
    WsConnection conexao,
    ListarVerificacoesRequestDto dto,
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
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Usuário não encontrado',
      );
    }

    if (usuario.userRole != UserRole.admin) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não está autorizado a fazer isso',
      );
    }
    final adminRepository = AdminRepository(
      SupabaseClientFactory.criarSecret(),
    );
    final response = await adminRepository.obterVerificacoes(dto.status);

    return ListarVerificacoesResponseDto(verificacoes: response);
  }

  Future<AprovarPrestadorResponseDto> aprovarPrestador(
    WsConnection conexao,
    AprovarPrestadorRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final adminId = _sessaoService.userIdDe(conexao);
    if (client == null || adminId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final usuarioRepository = UsuarioRepository(client);
    final usuario = await usuarioRepository.buscarPorId(adminId);
    if (usuario == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Usuário não encontrado',
      );
    }

    if (usuario.userRole != UserRole.admin) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não está autorizado a fazer isso',
      );
    }

    final adminRepository = AdminRepository(
      SupabaseClientFactory.criarSecret(),
    );
    final verificacao = await adminRepository.aprovarPrestador(
      verificacoId: dto.verificacaoId,
      adminId: adminId,
    );

    final usuarioPrestador = await UsuarioRepository(
      SupabaseClientFactory.criarSecret(),
    ).buscarPorId(verificacao.usuarioId);

    if (usuarioPrestador == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Usuário não encontrado',
      );
    }

    _sessaoService.enviarParaUsuario(
      usuarioPrestador.id,
      AprovarPrestadorResponseDto(usuario: usuarioPrestador),
    );

    return AprovarPrestadorResponseDto(
      usuario: usuarioPrestador,
      verificacao: verificacao,
    );
  }

  Future<void> rejeitarPrestador(
    WsConnection conexao,
    RejeitarPrestadorRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final adminId = _sessaoService.userIdDe(conexao);
    if (client == null || adminId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final usuarioRepository = UsuarioRepository(client);
    final usuario = await usuarioRepository.buscarPorId(adminId);
    if (usuario == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Usuário não encontrado',
      );
    }

    if (usuario.userRole != UserRole.admin) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não está autorizado a fazer isso',
      );
    }

    final adminRepository = AdminRepository(
      SupabaseClientFactory.criarSecret(),
    );
    final verificacao = await adminRepository.rejeitarPrestador(
      verificacoId: dto.verificacaoId,
      adminId: adminId,
    );

    final usuarioPrestador = await UsuarioRepository(
      SupabaseClientFactory.criarSecret(),
    ).buscarPorId(verificacao.usuarioId);

    if (usuarioPrestador == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Usuário não encontrado',
      );
    }

    _sessaoService.enviarParaUsuario(
      usuarioPrestador.id,
      RejeitarPrestadorResponseDto(motivo: 'Sua solicitação foi rejeitada.'),
    );
  }
}
