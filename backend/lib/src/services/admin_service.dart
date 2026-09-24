import 'package:backend/src/repositories/admin_repository.dart';
import 'package:backend/src/repositories/usuario_repository.dart';
import 'package:backend/src/services/arquivo_upload_service.dart';
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

    final clientSecret = SupabaseClientFactory.criarSecret();
    final adminRepository = AdminRepository(clientSecret);
    final verificacoes = await adminRepository.obterVerificacoes(dto.status);

    final comUrls = <VerificacaoComUrls>[];
    for (final verificacao in verificacoes) {
      final urls = <String>[];
      for (final arquivo in verificacao.arquivos) {
        final url = await ArquivoUploadService.urlAssinada(
          client: clientSecret,
          bucket: 'verificacoes',
          prefixo: verificacao.id,
          arquivo: arquivo,
        );
        urls.add(url);
      }
      comUrls.add(
        VerificacaoComUrls(verificacao: verificacao, urlsArquivos: urls),
      );
    }

    return ListarVerificacoesResponseDto(verificacoes: comUrls);
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

  Future<AdminListarContestacoesResponseDto> listarContestacoes(
    WsConnection conexao,
    AdminListarContestacoesRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final usuario = await UsuarioRepository(client).buscarPorId(userId);
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
    final contestacoes = await adminRepository.listarContestacoes(dto.status);

    return AdminListarContestacoesResponseDto(contestacoes: contestacoes);
  }

  Future<AdminResponderContestacaoResponseDto> responderContestacao(
    WsConnection conexao,
    AdminResponderContestacaoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final adminId = _sessaoService.userIdDe(conexao);
    if (client == null || adminId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final usuario = await UsuarioRepository(client).buscarPorId(adminId);
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

    final contestacao = await adminRepository.responderContestacao(
      contestacaoId: dto.contestacaoId,
      adminId: adminId,
      status: dto.status,
      resposta: dto.resposta,
      statusAgendamentoFinal: dto.statusAgendamentoFinal,
    );

    final aprovada = dto.status == StatusContestacao.resolvida;

    await _sessaoService.enviarParaUsuario(
      contestacao.contestadorId,
      NotificacaoDto(
        titulo: aprovada ? 'Contestação resolvida' : 'Contestação rejeitada',
        mensagem: dto.resposta,
        dados: {
          'contestacao_id': contestacao.id,
          'agendamento_id': contestacao.agendamentoId,
          'status': contestacao.status.valor,
        },
      ),
    );

    return AdminResponderContestacaoResponseDto(contestacao: contestacao);
  }

  Future<AdminListarDenunciasResponseDto> listarDenuncias(
    WsConnection conexao,
    AdminListarDenunciasRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final usuario = await UsuarioRepository(client).buscarPorId(userId);
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
    final denuncias = await adminRepository.listarDenuncias(dto.status);

    return AdminListarDenunciasResponseDto(denuncias: denuncias);
  }

  Future<AdminResponderDenunciaResponseDto> responderDenuncia(
    WsConnection conexao,
    AdminResponderDenunciaRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final adminId = _sessaoService.userIdDe(conexao);
    if (client == null || adminId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final usuario = await UsuarioRepository(client).buscarPorId(adminId);
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

    final denuncia = await adminRepository.responderDenuncia(
      denunciaId: dto.denunciaId,
      adminId: adminId,
      status: dto.status,
      resposta: dto.resposta,
      removerPrestador: dto.removerPrestador,
      banirUsuario: dto.banirUsuario,
    );

    final aprovada = dto.status == StatusDenuncia.resolvida;

    await _sessaoService.enviarParaUsuario(
      denuncia.denunciadorId,
      NotificacaoDto(
        titulo: aprovada ? 'Denúncia analisada' : 'Denúncia rejeitada',
        mensagem: dto.resposta,
        dados: {'denuncia_id': denuncia.id, 'status': denuncia.status.valor},
      ),
    );

    return AdminResponderDenunciaResponseDto(denuncia: denuncia);
  }
}
