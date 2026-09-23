import 'package:backend/src/services/arquivo_upload_service.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';
import '../repositories/chat_repository.dart';
import '../ws/ws_connection.dart';
import 'sessao_service.dart';

class ChatService {
  final SessaoService _sessaoService;
  ChatService(this._sessaoService);

  ErroDto _mapearErro(Object erro) {
    final mensagem = erro is PostgrestException
        ? erro.message
        : erro.toString();

    if (mensagem.contains('nao_autenticado')) {
      return ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Sessão inválida.',
      );
    }
    if (mensagem.contains('usuario_igual_prestador')) {
      return ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Você não pode iniciar uma conversa consigo mesmo.',
      );
    }
    if (mensagem.contains('prestador_nao_aprovado')) {
      return ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Só é possível iniciar conversa com um prestador aprovado.',
      );
    }
    if (mensagem.contains('nao_participante')) {
      return ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não participa dessa conversa.',
      );
    }
    if (mensagem.contains('conversa_indisponivel')) {
      return ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem:
            'Essa conversa não está mais disponível para envio de mensagens.',
      );
    }
    if (mensagem.contains('conversa_nao_encontrada')) {
      return ErroDto(
        codigo: ErroCodigo.naoEncontrado,
        mensagem: 'Conversa não encontrada.',
      );
    }
    if (mensagem.contains('texto_vazio')) {
      return ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'A mensagem não pode ser vazia.',
      );
    }
    return ErroDto(
      codigo: ErroCodigo.erroInterno,
      mensagem: 'Erro ao processar a operação.',
    );
  }

  SupabaseClient _clientOuFalha(WsConnection conexao) {
    final client = _sessaoService.clientDe(conexao);
    if (client == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }
    return client;
  }

  String _userIdOuFalha(WsConnection conexao) {
    final userId = _sessaoService.userIdDe(conexao);
    if (userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }
    return userId;
  }

  Future<CriarConversaResponseDto> criarConversa(
    WsConnection conexao,
    CriarConversaRequestDto dto,
  ) async {
    final client = _clientOuFalha(conexao);
    try {
      final id = await ChatRepository(
        client,
      ).criarConversa(idPrestador: dto.prestadorId);
      return CriarConversaResponseDto(conversaId: id);
    } catch (erro) {
      throw _mapearErro(erro);
    }
  }

  Future<ListarConversasResponseDto> listarConversas(
    WsConnection conexao,
  ) async {
    final client = _clientOuFalha(conexao);
    try {
      final linhas = await ChatRepository(client).listarConversasComDetalhes();
      return ListarConversasResponseDto(
        conversas: linhas.map(ConversaResumo.fromMap).toList(),
      );
    } catch (erro) {
      throw _mapearErro(erro);
    }
  }

  Future<EnviarMensagemResponseDto> enviarMensagem(
    WsConnection conexao,
    EnviarMensagemRequestDto dto,
  ) async {
    final client = _clientOuFalha(conexao);
    final userId = _userIdOuFalha(conexao);
    final repositorio = ChatRepository(client);

    ArquivoValidado? validado;
    if (dto.arquivo != null) {
      validado = ArquivoUploadService.validar(dto.arquivo!);
      if (validado == null) {
        throw ErroDto(
          codigo: ErroCodigo.dadosInvalidos,
          mensagem: 'Arquivo inválido.',
        );
      }
    }

    final tipoMensagem = validado?.tipo.valor ?? 'texto';

    Map<String, dynamic> linha;
    try {
      linha = await repositorio.enviarMensagem(
        idConversa: dto.idConversa,
        texto: dto.texto,
        tipo: tipoMensagem,
      );
    } catch (erro) {
      throw _mapearErro(erro);
    }

    var mensagem = Mensagem.fromMap(linha);
    String? urlArquivo;

    if (dto.arquivo != null && validado != null) {
      final arquivoId = await repositorio.registrarArquivoMensagem(
        mensagemId: mensagem.id,
        nomeOriginal: dto.arquivo!.nomeOriginal,
        tipoArquivo: validado.tipo.valor,
        mimeType: validado.mimeType,
      );

      try {
        await ArquivoUploadService.upload(
          client: client,
          bucket: 'conversas',
          prefixo: mensagem.id,
          arquivoId: arquivoId,
          extensao: dto.arquivo!.extensao.toLowerCase(),
          validado: validado,
        );

        final arquivoAnexado = ArquivoAnexado(
          id: arquivoId,
          nomeOriginal: dto.arquivo!.nomeOriginal,
          tipo: validado.tipo,
          mimeType: validado.mimeType,
          criadoEm: DateTime.now().toUtc(),
        );

        urlArquivo = await ArquivoUploadService.urlAssinada(
          client: client,
          bucket: 'conversas',
          prefixo: mensagem.id,
          arquivo: arquivoAnexado,
        );

        mensagem = Mensagem(
          id: mensagem.id,
          idConversa: mensagem.idConversa,
          idRemetente: mensagem.idRemetente,
          texto: mensagem.texto,
          tipo: mensagem.tipo,
          enviadoEm: mensagem.enviadoEm,
          arquivo: arquivoAnexado,
        );
      } catch (e) {
        await client.from('mensagem_arquivos').delete().eq('id', arquivoId);
      }
    }

    final mensagemComUrl = MensagemComUrl(
      mensagem: mensagem,
      urlArquivo: urlArquivo,
    );

    final participantes = await repositorio.buscarParticipantes(dto.idConversa);
    if (participantes != null) {
      final idA = participantes['usuario_a_id'] as String;
      final idB = participantes['usuario_b_id'] as String;
      final idOutro = idA == userId ? idB : idA;
      _sessaoService.enviarParaUsuario(
        idOutro,
        NovaMensagemDto(mensagem: mensagemComUrl),
      );
    }

    return EnviarMensagemResponseDto(mensagem: mensagemComUrl);
  }

  Future<ListarMensagensResponseDto> listarMensagens(
    WsConnection conexao,
    ListarMensagensRequestDto dto,
  ) async {
    final client = _clientOuFalha(conexao);
    final repositorio = ChatRepository(client);

    List<Map<String, dynamic>> linhas;
    try {
      linhas = await repositorio.listarMensagens(
        dto.idConversa,
        antesDe: dto.antesDe,
        limite: dto.limite,
      );
    } catch (erro) {
      throw _mapearErro(erro);
    }

    final comUrls = <MensagemComUrl>[];
    for (final linha in linhas) {
      final mensagem = Mensagem.fromMap(linha);
      String? url;
      if (mensagem.arquivo != null) {
        url = await ArquivoUploadService.urlAssinada(
          client: client,
          bucket: 'conversas',
          prefixo: mensagem.id,
          arquivo: mensagem.arquivo!,
        );
      }
      comUrls.add(MensagemComUrl(mensagem: mensagem, urlArquivo: url));
    }

    return ListarMensagensResponseDto(mensagens: comUrls);
  }
}
