import 'dart:convert';

import 'package:backend/src/repositories/usuario_repository.dart';
import 'package:backend/src/services/arquivo_upload_service.dart';
import 'package:backend/src/supabase/supabase_client_factory.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';
import 'sessao_service.dart';
import '../ws/ws_connection.dart';

const _limiteArquivosPorVerificacao = 5;
const _limiteBytesVerificacao = 10 * 1024 * 1024;

const _extensoesAvatarPermitidas = {
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'webp': 'image/webp',
};

class UsuarioService {
  final SessaoService _sessaoService;
  final SupabaseClient _clienteAnonimo;
  UsuarioService(this._sessaoService)
    : _clienteAnonimo = SupabaseClientFactory.criarAnonimo();

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

    if (dto.arquivos.isEmpty) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Envie ao menos um documento para solicitar ser prestador.',
      );
    }

    if (dto.arquivos.length > _limiteArquivosPorVerificacao) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem:
            'Máximo de $_limiteArquivosPorVerificacao arquivos por solicitação.',
      );
    }

    final validados = <MapEntry<ArquivoUpload, ArquivoValidado>>[];
    for (final arquivo in dto.arquivos) {
      final validado = ArquivoUploadService.validar(
        arquivo,
        limiteBytes: _limiteBytesVerificacao,
      );
      if (validado == null) {
        throw ErroDto(
          codigo: ErroCodigo.dadosInvalidos,
          mensagem:
              'Arquivo "${arquivo.nomeOriginal}" inválido ou excede 10MB.',
        );
      }
      validados.add(MapEntry(arquivo, validado));
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

    var salvos = 0;
    for (final entry in validados) {
      final arquivo = entry.key;
      final validado = entry.value;

      final arquivoId = await usuarioRepository.registrarArquivoVerificacao(
        verificacaoId: verificacao.id,
        nomeOriginal: arquivo.nomeOriginal,
        tipoArquivo: validado.tipo.valor,
        mimeType: validado.mimeType,
      );

      try {
        await ArquivoUploadService.upload(
          client: client,
          bucket: 'verificacoes',
          prefixo: verificacao.id,
          arquivoId: arquivoId,
          extensao: arquivo.extensao.toLowerCase(),
          validado: validado,
        );
        salvos++;
      } catch (_) {
        await client.from('verificacao_arquivos').delete().eq('id', arquivoId);
      }
    }

    return SolicitarPrestadorResponseDto(
      usuario: usuario,
      verificacao: verificacao,
      quantidadeArquivosSalvos: salvos,
    );
  }

  Future<ObterPerfilPublicoResponseDto> obterPerfilPublico(
    WsConnection conexao,
    ObterPerfilPublicoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao) ?? _clienteAnonimo;

    final usuarioRepository = UsuarioRepository(client);

    final perfilPublico = await usuarioRepository.obterPerfilPublico(
      dto.usuarioId,
    );

    if (perfilPublico == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoEncontrado,
        mensagem: 'Usuário não encontrado',
      );
    }

    return perfilPublico;
  }

  Future<PerfilCompletoResponseDto> obterPerfilCompleto(
    WsConnection conexao,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    if (client == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final perfilCompleto = await UsuarioRepository(
      client,
    ).obterPerfilCompleto();

    return PerfilCompletoResponseDto(perfil: perfilCompleto);
  }

  Future<AtualizarAvatarResponseDto> atualizarAvatar(
    WsConnection conexao,
    AtualizarAvatarRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    final accessToken = _sessaoService.accessTokenDe(conexao);

    if (client == null || userId == null || accessToken == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final extensao = dto.extensao.toLowerCase();
    final mimeType = _extensoesAvatarPermitidas[extensao];
    if (mimeType == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Formato de imagem não suportado.',
      );
    }

    late final List<int> bytes;
    try {
      bytes = base64Decode(dto.imagemBase64);
    } catch (_) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Imagem inválida.',
      );
    }

    const limiteBytes = 5 * 1024 * 1024;
    if (bytes.length > limiteBytes) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Imagem excede o limite de 5MB.',
      );
    }

    final url = await UsuarioRepository(client).uploadAvatar(
      usuarioId: userId,
      bytes: bytes,
      extensao: extensao,
      mimeType: mimeType,
    );

    return AtualizarAvatarResponseDto(avatarUrl: url);
  }
}
