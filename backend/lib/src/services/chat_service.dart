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
      ).criarConversa(idPrestador: dto.idPrestador);
      return CriarConversaResponseDto(idConversa: id);
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

  Future<ListarMensagensResponseDto> listarMensagens(
    WsConnection conexao,
    ListarMensagensRequestDto dto,
  ) async {
    final client = _clientOuFalha(conexao);
    final userId = _userIdOuFalha(conexao);
    final repositorio = ChatRepository(client);

    final participantes = await repositorio.buscarParticipantes(dto.idConversa);
    if (participantes == null ||
        (participantes['usuario_a_id'] != userId &&
            participantes['usuario_b_id'] != userId)) {
      throw ErroDto(
        codigo: ErroCodigo.naoPermitido,
        mensagem: 'Você não participa dessa conversa.',
      );
    }

    final linhas = await repositorio.listarMensagens(
      dto.idConversa,
      antesDe: dto.antesDe,
      limite: dto.limite,
    );
    return ListarMensagensResponseDto(
      mensagens: linhas.map(Mensagem.fromMap).toList(),
    );
  }

  Future<EnviarMensagemResponseDto> enviarMensagem(
    WsConnection conexao,
    EnviarMensagemRequestDto dto,
  ) async {
    final client = _clientOuFalha(conexao);
    final userId = _userIdOuFalha(conexao);

    Map<String, dynamic> linha;
    try {
      linha = await ChatRepository(
        client,
      ).enviarMensagem(idConversa: dto.idConversa, texto: dto.texto);
    } catch (erro) {
      throw _mapearErro(erro);
    }

    final mensagem = Mensagem.fromMap(linha);

    final participantes = await ChatRepository(
      client,
    ).buscarParticipantes(dto.idConversa);
    if (participantes != null) {
      final idA = participantes['usuario_a_id'] as String;
      final idB = participantes['usuario_b_id'] as String;
      final idOutro = idA == userId ? idB : idA;
      _sessaoService.enviarParaUsuario(
        idOutro,
        NovaMensagemDto(mensagem: mensagem),
      );
    }

    return EnviarMensagemResponseDto(mensagem: mensagem);
  }
}
