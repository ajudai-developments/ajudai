import 'package:backend/src/services/arquivo_upload_service.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';
import '../repositories/denuncia_repository.dart';
import '../services/sessao_service.dart';
import '../ws/ws_connection.dart';

const _limiteArquivosPorDenuncia = 5;

class DenunciaService {
  final SessaoService _sessaoService;
  DenunciaService(this._sessaoService);

  Future<CriarDenunciaResponseDto> criarDenuncia(
    WsConnection conexao,
    CriarDenunciaRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    if (client == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    if (dto.arquivos.length > _limiteArquivosPorDenuncia) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem:
            'Máximo de $_limiteArquivosPorDenuncia arquivos por denúncia.',
      );
    }

    final repositorio = DenunciaRepository(client);

    String denunciaId;
    try {
      denunciaId = await repositorio.criarDenuncia(
        usuarioId: dto.usuarioId,
        tipo: dto.tipoDenuncia.valor,
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
        denunciaId: denunciaId,
        nomeOriginal: arquivo.nomeOriginal,
        tipoArquivo: validado.tipo.valor,
        mimeType: validado.mimeType,
      );

      await ArquivoUploadService.upload(
        client: client,
        bucket: 'denuncias',
        prefixo: denunciaId,
        arquivoId: arquivoId,
        extensao: arquivo.extensao.toLowerCase(),
        validado: validado,
      );

      salvos++;
    }

    return CriarDenunciaResponseDto(
      idDenuncia: denunciaId,
      quantidadeArquivosSalvos: salvos,
    );
  }

  ErroDto _mapearErro(Object erro) {
    final mensagem = erro is PostgrestException
        ? erro.message
        : erro.toString();
    if (mensagem.contains('nao_pode_denunciar_a_si_mesmo')) {
      return ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'Você não pode denunciar a si mesmo.',
      );
    }
    if (mensagem.contains('descricao_vazia')) {
      return ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'A descrição não pode ser vazia.',
      );
    }
    return ErroDto(
      codigo: ErroCodigo.erroInterno,
      mensagem: 'Erro ao processar a denúncia.',
    );
  }

  Future<ListarMinhasDenunciasResponseDto> listarMinhasDenuncias(
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

    final repositorio = DenunciaRepository(client);
    final denuncias = await repositorio.listarMinhasDenuncias(userId);

    final comUrls = <DenunciaComUrls>[];
    for (final denuncia in denuncias) {
      final urls = <String>[];
      for (final arquivo in denuncia.arquivos) {
        final url = await ArquivoUploadService.urlAssinada(
          client: client,
          bucket: 'denuncias',
          prefixo: denuncia.id,
          arquivo: arquivo,
        );

        urls.add(url);
      }
      comUrls.add(DenunciaComUrls(denuncia: denuncia, urlsArquivos: urls));
    }

    return ListarMinhasDenunciasResponseDto(denuncias: comUrls);
  }
}
