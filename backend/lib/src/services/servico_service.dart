import 'package:backend/src/repositories/servico_repository.dart';
import 'package:backend/src/repositories/usuario_repository.dart';
import 'package:backend/src/supabase/supabase_client_factory.dart';
import 'package:shared/shared.dart';
import 'sessao_service.dart';
import '../ws/ws_connection.dart';

class ServicoService {
  final SessaoService _sessaoService;

  ServicoService(this._sessaoService);

  Future<CriarServicoOferecidoResponseDto> criarOferecido(
    WsConnection conexao,
    CriarServicoOferecidoRequestDto dto,
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
    if (usuario.userRole != UserRole.prestador ||
        usuario.statusPrestador != StatusPrestador.aprovado) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não está autorizado a fazer isso',
      );
    }

    if (dto.valor < 0) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Valor inválido',
      );
    }

    final servicoOferecido = await ServicoRepository(client).criarOferecido(
      servicoId: dto.servicoId,
      usuarioId: userId,
      descricao: dto.descricao,
      valor: dto.valor,
    );

    return CriarServicoOferecidoResponseDto(servicoOferecido: servicoOferecido);
  }

  Future<ListarMeusServicosOferecidosResponseDto> listarMeus(
    WsConnection conexao,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final servicosOferecidos = await ServicoRepository(
      client,
    ).listarOferecidosPorPrestador(userId);

    return ListarMeusServicosOferecidosResponseDto(
      servicosOferecidos: servicosOferecidos,
    );
  }

  Future<ObterServicoOferecidoResponseDto> obterDetalhe(
    WsConnection conexao,
    ObterServicoOferecidoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    if (client == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final detalhe = await ServicoRepository(
      client,
    ).obterDetalheCompleto(dto.servicoOferecidoId);
    if (detalhe == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Serviço oferecido não encontrado',
      );
    }

    return detalhe;
  }

  Future<ListarServicosResponseDto> listarServicos(
    WsConnection conexao,
    ListarServicosRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    if (client == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final servicos = await ServicoRepository(
      SupabaseClientFactory.criarSecret(),
    ).listarServicosPorCategoria(dto.categoriaId);

    return ListarServicosResponseDto(servicos: servicos);
  }
}
