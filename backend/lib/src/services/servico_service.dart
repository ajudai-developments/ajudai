import 'package:backend/src/repositories/servico_repository.dart';
import 'package:backend/src/repositories/usuario_repository.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';
import 'sessao_service.dart';
import '../ws/ws_connection.dart';

class ServicoService {
  final SessaoService _sessaoService;
  final SupabaseClient _clientAnonimo;
  final ServicoRepository _servicoRepository;

  ServicoService(
    this._sessaoService,
    this._clientAnonimo,
    this._servicoRepository,
  );

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

  Future<ListarServicosOferecidosPorCategoriaResponseDto>
  listarServicosOferecidosPorCategoria(
    WsConnection conexao,
    ListarServicosOferecidosPorCategoriaRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao) ?? _clientAnonimo;
    final userid = _sessaoService.userIdDe(conexao);

    final servicos = await ServicoRepository(client)
        .listarServicosOferecidosPorCategoria(
          dto.categoriaId,
          usuarioAtualId: userid,
        );

    return ListarServicosOferecidosPorCategoriaResponseDto(servicos: servicos);
  }

  Future<ListarServicosOferecidosPorServicoResponseDto>
  listarServicosOferecidosPorServico(
    WsConnection conexao,
    ListarServicosOferecidosPorServicoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao) ?? _clientAnonimo;
    final userid = _sessaoService.userIdDe(conexao);

    final servicos = await ServicoRepository(
      client,
    ).listarServicosOferecidosPorservico(dto.servicoId, usuarioAtualId: userid);

    return ListarServicosOferecidosPorServicoResponseDto(servicos: servicos);
  }

  Future<ListarServicosResponseDto> listarServicos(
    WsConnection conexao,
    ListarServicosRequestDto dto,
  ) async {
    final servicos = await _servicoRepository.listarServicos(
      categoriaId: dto.categoriaId,
    );

    return ListarServicosResponseDto(servicos: servicos);
  }

  Future<EditarServicoOferecidoResponseDto> editarServicoOferecido(
    WsConnection conexao,
    EditarServicoOferecidoRequestDto dto,
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
        codigo: ErroCodigo.usuarioInexistente,
        mensagem: "Esse usuário não existe",
      );
    }

    if (usuario.userRole != UserRole.prestador) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: "Você não está autorizado a fazer isso",
      );
    }

    if (dto.descricao == null && dto.valor == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: "Nenhum campo para atualizar encontrado",
      );
    }

    final servico = await _servicoRepository.atualizarServico(
      dto.servicoOferecidoId,
      usuarioId: userId,
      descricao: dto.descricao,
      valor: dto.valor,
    );

    return EditarServicoOferecidoResponseDto(servico: servico);
  }

  Future<DesativarServicoOferecidoResponseDto> desativarServicoOferecido(
    WsConnection conexao,
    DesativarServicoOferecidoRequestDto dto,
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
        codigo: ErroCodigo.usuarioInexistente,
        mensagem: "Esse usuário não existe",
      );
    }

    if (usuario.userRole != UserRole.prestador) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: "Você não está autorizado a fazer isso",
      );
    }

    await _servicoRepository.desativarServicoOferecido(
      dto.servicoOferecidoId,
      usuarioId: userId,
    );

    return DesativarServicoOferecidoResponseDto(
      mensagem: "Serviço excluído com sucesso!",
    );
  }
}
