import 'package:backend/src/repositories/agendamento_repository.dart';
import 'package:backend/src/services/arquivo_upload_service.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';
import '../repositories/contestacao_repository.dart';
import '../services/sessao_service.dart';
import '../ws/ws_connection.dart';

const _limiteArquivosPorContestacao = 5;

class ContestacaoService {
  final SessaoService _sessaoService;
  ContestacaoService(this._sessaoService);

  Future<CriarContestacaoResponseDto> criarContestacao(
    WsConnection conexao,
    CriarContestacaoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);

    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final agendamento = await AgendamentoRepository(
      client,
    ).buscarPorId(dto.agendamentoId);

    if (agendamento == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoEncontrado,
        mensagem: 'Agendamento não encontrado',
      );
    }

    if (agendamento.usuarioId != userId && agendamento.prestadorId != userId) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Você não participou desse agendamento.',
      );
    }

    final jaContestado = await client
        .from('contestacoes_agendamento')
        .select('id')
        .eq('agendamento_id', dto.agendamentoId)
        .eq('contestador_id', userId)
        .maybeSingle();

    if (jaContestado != null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Você já contestou esse agendamento.',
      );
    }

    if (agendamento.status != StatusAgendamento.concluido &&
        agendamento.status != StatusAgendamento.cancelado &&
        agendamento.status != StatusAgendamento.aguardandoConfirmacao) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem:
            'A contestação só pode ser criada para agendamentos concluídos, cancelados ou aguardando confirmação.',
      );
    }

    if (dto.arquivos.length > _limiteArquivosPorContestacao) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem:
            'Máximo de $_limiteArquivosPorContestacao arquivos por contestação.',
      );
    }

    final repositorio = ContestacaoRepository(client);

    String contestacaoId;
    try {
      contestacaoId = await repositorio.criarContestacao(
        agendamentoId: dto.agendamentoId,
        descricao: dto.descricao,
      );
    } catch (erro) {
      throw _mapearErro(erro);
    }

    var salvos = 0;
    for (final arquivo in dto.arquivos) {
      final validado = ArquivoUploadService.validar(arquivo);
      if (validado == null) continue;

      final arquivoId = await repositorio.registrarArquivo(
        contestacaoId: contestacaoId,
        nomeOriginal: arquivo.nomeOriginal,
        tipoArquivo: validado.tipo.valor,
        mimeType: validado.mimeType,
      );

      try {
        await ArquivoUploadService.upload(
          client: client,
          bucket: 'contestamentos',
          prefixo: contestacaoId,
          arquivoId: arquivoId,
          extensao: arquivo.extensao.toLowerCase(),
          validado: validado,
        );
        salvos++;
      } catch (e) {
        await client.from('contestacao_arquivos').delete().eq('id', arquivoId);
      }
    }

    return CriarContestacaoResponseDto(
      idContestacao: contestacaoId,
      quantidadeArquivosSalvos: salvos,
    );
  }

  Future<ListarMinhasContestacoesResponseDto> listarMinhasContestacoes(
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

    final repositorio = ContestacaoRepository(client);
    final contestacoes = await repositorio.listarMinhasContestacoes(userId);

    final comUrls = <ContestacaoComUrls>[];
    for (final contestacao in contestacoes) {
      final urls = <String>[];
      for (final arquivo in contestacao.arquivos) {
        final url = await ArquivoUploadService.urlAssinada(
          client: client,
          bucket: 'contestamentos',
          prefixo: contestacao.id,
          arquivo: arquivo,
        );
        urls.add(url);
      }
      comUrls.add(
        ContestacaoComUrls(contestacao: contestacao, urlsArquivos: urls),
      );
    }

    return ListarMinhasContestacoesResponseDto(contestacoes: comUrls);
  }

  ErroDto _mapearErro(Object erro) {
    final mensagem = erro is PostgrestException
        ? erro.message
        : erro.toString();
    if (mensagem.contains('contestacoes_agendamento_unica')) {
      return ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Você já contestou esse agendamento.',
      );
    }
    if (mensagem.contains('nao_participante')) {
      return ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Você não participou desse agendamento.',
      );
    }
    if (mensagem.contains('descricao_vazia')) {
      return ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'A descrição não pode ser vazia.',
      );
    }
    if (mensagem.contains('nao_autenticado')) {
      return ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }
    return ErroDto(
      codigo: ErroCodigo.erroInterno,
      mensagem: 'Erro ao processar a contestação.',
    );
  }
}
