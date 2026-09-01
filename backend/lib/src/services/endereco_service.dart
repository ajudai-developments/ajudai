import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';
import '../clients/cep_client.dart';
import '../repositories/endereco_repository.dart';
import 'sessao_service.dart';
import '../ws/ws_connection.dart';

class EnderecoService {
  final CepClient _cepClient;
  final SessaoService _sessaoService;

  EnderecoService(this._cepClient, this._sessaoService);

  Future<ConsultarCepResponseDto> consultarCep(
    ConsultarCepRequestDto dto,
  ) async {
    final cepLimpo = dto.cep.replaceAll(RegExp(r'\D'), '');

    if (cepLimpo.length != 8) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'CEP inválido',
      );
    }

    final dados = await _cepClient.buscarPorCep(cepLimpo);
    if (dados == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'CEP não encontrado',
      );
    }

    return ConsultarCepResponseDto(
      cep: cepLimpo,
      logradouro: dados.logradouro,
      bairro: dados.bairro,
      cidade: dados.cidade,
      estado: dados.estado,
    );
  }

  Future<CriarEnderecoResponseDto> criarEndereco(
    WsConnection conexao,
    CriarEnderecoRequestDto dto,
  ) async {
    final client = _sessaoService.clientDe(conexao);
    final userId = _sessaoService.userIdDe(conexao);
    if (client == null || userId == null) {
      throw ErroDto(
        codigo: ErroCodigo.naoAutenticado,
        mensagem: 'Não autenticado',
      );
    }

    final cepLimpo = dto.cep.replaceAll(RegExp(r'\D'), '');
    if (cepLimpo.length != 8) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'CEP inválido',
      );
    }

    final dados = await _cepClient.buscarPorCep(cepLimpo);
    if (dados == null) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'CEP não encontrado',
      );
    }

    final enderecoRepository = EnderecoRepository(client);

    try {
      final endereco = await enderecoRepository.criar(
        usuarioId: userId,
        nome: dto.nome,
        cep: cepLimpo,
        numero: dto.numero,
        complemento: dto.complemento,
        logradouro: dados.logradouro,
        bairro: dados.bairro,
        cidade: dados.cidade,
        estado: dados.estado,
      );

      return CriarEnderecoResponseDto(endereco: endereco);
    } on PostgrestException catch (e) {
      if (e.message == 'limite_enderecos_excedido') {
        throw ErroDto(
          codigo: ErroCodigo.limiteEnderecosExcedido,
          mensagem: 'Você já atingiu o limite de 3 endereços cadastrados',
        );
      }
      rethrow;
    }
  }

  Future<ObterMeusEnderecosResponseDto> obterMeusEnderecos(
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

    final enderecoRepository = EnderecoRepository(client);

    try {
      final enderecos = await enderecoRepository.obterEnderecoDe(
        userId: userId,
      );

      return ObterMeusEnderecosResponseDto(enderecos: enderecos);
    } catch (e) {
      rethrow;
    }
  }
}
