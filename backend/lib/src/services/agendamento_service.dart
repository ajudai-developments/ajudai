import 'package:backend/src/models/endereco_resolvido.dart';
import 'package:backend/src/repositories/agendamento_repository.dart';
import 'package:backend/src/repositories/endereco_repository.dart';
import 'package:backend/src/repositories/servico_repository.dart';
import 'package:backend/src/services/pagamento_service.dart';
import 'package:backend/src/services/sessao_service.dart';
import 'package:backend/src/ws/ws_connection.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

Future<EnderecoResolvido> _resolverEndereco(
  SupabaseClient client,
  String userId,
  dynamic dto,
) async {
  if (dto.enderecoId != null) {
    final endereco = await EnderecoRepository(
      client,
    ).buscarPorId(dto.enderecoId);
    if (endereco == null || endereco.usuarioId != userId) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Endereço não encontrado',
      );
    }
    return EnderecoResolvido(
      id: endereco.id,
      logradouro: endereco.logradouro,
      numero: endereco.numero,
      complemento: endereco.complemento,
      bairro: endereco.bairro,
      cidade: endereco.cidade,
      estado: endereco.estado,
      cep: endereco.cep,
    );
  }

  final camposManuais = [
    dto.enderecoLogradouro,
    dto.enderecoNumero,
    dto.enderecoBairro,
    dto.enderecoCidade,
    dto.enderecoEstado,
    dto.enderecoCep,
  ];
  if (camposManuais.any((c) => c == null)) {
    throw ErroDto(
      codigo: ErroCodigo.dadosInvalidos,
      mensagem: 'Endereço incompleto',
    );
  }

  return EnderecoResolvido(
    logradouro: dto.enderecoLogradouro!,
    numero: dto.enderecoNumero!,
    complemento: dto.enderecoComplemento,
    bairro: dto.enderecoBairro!,
    cidade: dto.enderecoCidade!,
    estado: dto.enderecoEstado!,
    cep: dto.enderecoCep!,
  );
}

class AgendamentoService {
  final SessaoService _sessaoService;
  final PagamentoService _pagamentoService;

  AgendamentoService(this._sessaoService, this._pagamentoService);

  Future<CriarAgendamentoResponseDto> criarPreview(
    WsConnection conexao,
    CriarAgendamentoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    AgendamentoValidator.validar(
      agoraUtc: DateTime.now().toUtc(),
      horaInicioUtc: dto.horaInicio,
      horaFimUtc: dto.horaFim,
    );

    final detalhe = await ServicoRepository(
      client,
    ).obterDetalheParaAgendamento(dto.servicoOferecidoId);
    if (detalhe == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Serviço não encontrado ou indisponível',
      );
    }

    final endereco = await _resolverEndereco(client, userId, dto);

    return CriarAgendamentoResponseDto(
      servicoOferecidoId: detalhe.servicoOferecidoId,
      nomeServico: detalhe.servicoNome,
      nomePrestador: detalhe.prestadorNome,
      valor: detalhe.valor,
      horaInicio: dto.horaInicio,
      horaFim: dto.horaFim,
      enderecoResumo: endereco.resumo,
    );
  }

  Future<ConfirmarPagamentoResponseDto> confirmarPagamento(
    WsConnection conexao,
    ConfirmarPagamentoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    AgendamentoValidator.validar(
      agoraUtc: DateTime.now().toUtc(),
      horaInicioUtc: dto.horaInicio,
      horaFimUtc: dto.horaFim,
    );

    final detalhe = await ServicoRepository(
      client,
    ).obterDetalheParaAgendamento(dto.servicoOferecidoId);
    if (detalhe == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Serviço não encontrado ou indisponível',
      );
    }

    final endereco = await _resolverEndereco(client, userId, dto);

    final pagamentoAprovado = await _pagamentoService.processar(
      valor: detalhe.valor,
      metodoPagamento: dto.metodoPagamento,
    );

    if (!pagamentoAprovado) {
      throw ErroDto(
        codigo: ErroCodigo.pagamentoRecusado,
        mensagem: 'Pagamento não foi aprovado',
      );
    }

    final agendamento = await AgendamentoRepository(client).criar(
      usuarioId: userId,
      prestadorId: detalhe.prestadorId,
      servicoOferecidoId: detalhe.servicoOferecidoId,
      endereco: endereco,
      horaInicio: dto.horaInicio,
      horaFim: dto.horaFim,
      valor: detalhe.valor,
    );

    _sessaoService.enviarParaUsuario(
      detalhe.prestadorId,
      NotificacaoDto(
        titulo: 'Novo agendamento',
        mensagem: '${detalhe.prestadorNome}, você recebeu um novo agendamento',
        dados: {'agendamentoId': agendamento.id},
      ),
    );

    return ConfirmarPagamentoResponseDto(agendamento: agendamento);
  }
}
