// lib/src/features/endereco/data/endereco_repository.dart
import 'package:shared/shared.dart';

import '../../../ws/ws_client.dart';

class EnderecoRepository {
  final WsClient _wsClient;

  EnderecoRepository(this._wsClient);

  Future<List<Endereco>> obterMeusEnderecos() async {
    final request = ObterMeusEnderecosRequestDto();
    
    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.obterMeusEnderecosOk.valor},
    );

    final dto = ObterMeusEnderecosResponseDto.fromJson(response);
    return dto.enderecos;
  }

  Future<Endereco> criarEndereco({
    required String nome,
    required String cep,
    required String numero,
    String? complemento,
  }) async {
    // Primeiro consulta o CEP
    final cepResponse = await consultarCep(cep);
    
    final request = CriarEnderecoRequestDto(
      nome: nome,
      cep: cep,
      numero: numero,
      complemento: complemento,
    );
    
    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.criarEnderecoOk.valor},
    );

    final dto = CriarEnderecoResponseDto.fromJson(response);
    return dto.endereco;
  }

  Future<ConsultarCepResponseDto> consultarCep(String cep) async {
    final request = ConsultarCepRequestDto(cep: cep);
    
    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.consultarCepOk.valor},
    );

    return ConsultarCepResponseDto.fromJson(response);
  }

  Future<Endereco> editarEndereco({
    required String enderecoId,
    required String nome,
    required String cep,
    required String numero,
    String? complemento,
  }) async {
    final request = EditarEnderecoRequestDto(
      enderecoId: enderecoId,
      nome: nome,
      cep: cep,
      numero: numero,
      complemento: complemento,
    );
    
    final response = await _wsClient.enviarEAguardar(
      request,
      tiposEsperados: {TipoMensagem.editarEnderecoOk.valor},
    );

    final dto = EditarEnderecoResponseDto.fromJson(response);
    return dto.endereco;
  }
}