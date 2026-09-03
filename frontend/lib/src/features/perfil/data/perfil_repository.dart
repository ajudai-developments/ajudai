import 'package:shared/shared.dart';

import '../../../ws/ws_client.dart';

class PerfilRepository {
  final WsClient _wsClient;

  PerfilRepository(this._wsClient);

  Future<List<Endereco>> obterMeusEnderecos() async {
    final resposta = await _wsClient.enviarEAguardar(
      const ObterMeusEnderecosRequestDto(),
      tiposEsperados: {TipoMensagem.obterMeusEnderecosOk.valor},
    );
    return ObterMeusEnderecosResponseDto.fromJson(resposta).enderecos;
  }

  Future<ConsultarCepResponseDto> consultarCep(String cep) async {
    final resposta = await _wsClient.enviarEAguardar(
      ConsultarCepRequestDto(cep: cep),
      tiposEsperados: {TipoMensagem.consultarCepOk.valor},
    );
    return ConsultarCepResponseDto.fromJson(resposta);
  }

  Future<Endereco> criarEndereco({
    required String nome,
    required String cep,
    required String numero,
    String? complemento,
  }) async {
    final resposta = await _wsClient.enviarEAguardar(
      CriarEnderecoRequestDto(
        nome: nome,
        cep: cep,
        numero: numero,
        complemento: complemento,
      ),
      tiposEsperados: {TipoMensagem.criarEnderecoOk.valor},
    );
    return CriarEnderecoResponseDto.fromJson(resposta).endereco;
  }

  Future<Endereco> editarEndereco({
    required String enderecoId,
    required String nome,
    required String cep,
    required String numero,
    String? complemento,
  }) async {
    final resposta = await _wsClient.enviarEAguardar(
      EditarEnderecoRequestDto(
        enderecoId: enderecoId,
        nome: nome,
        cep: cep,
        numero: numero,
        complemento: complemento,
      ),
      tiposEsperados: {TipoMensagem.criarEnderecoOk.valor},
    );
    return EditarEnderecoResponseDto.fromJson(resposta).endereco;
  }

  Future<SolicitarPrestadorResponseDto> solicitarPrestador() async {
    final resposta = await _wsClient.enviarEAguardar(
      SolicitarPrestadorRequestDto(),
      tiposEsperados: {TipoMensagem.solicitarPrestadorOk.valor},
    );
    return SolicitarPrestadorResponseDto.fromJson(resposta);
  }
}