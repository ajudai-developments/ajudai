import 'package:shared/shared.dart';

import '../../core/ws/ws_client.dart';
import '../../core/ws/ws_message_stream.dart';

/// Repositório de endereços do usuário logado.
class EnderecoRepository {
  /// Consulta um CEP e retorna os dados pra pré-preencher o formulário
  /// de endereço (logradouro, bairro, cidade, estado). Retorna o DTO
  /// inteiro em vez de um Endereco, já que o CEP sozinho não é um
  /// endereço completo (falta número/complemento, que o usuário digita).
  Future<ConsultarCepResponseDto> consultarCep(String cep) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(ConsultarCepRequestDto(cep: cep));

    final json =
        await WsMessageStream.instance.aguardar(TipoMensagem.consultarCepOk);
    return ConsultarCepResponseDto.fromJson(json);
  }

  Future<Endereco> criarEndereco({
    required String nome,
    required String cep,
    required String numero,
    String? complemento,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      CriarEnderecoRequestDto(
        nome: nome,
        cep: cep,
        numero: numero,
        complemento: complemento,
      ),
    );

    final json =
        await WsMessageStream.instance.aguardar(TipoMensagem.criarEnderecoOk);
    return CriarEnderecoResponseDto.fromJson(json).endereco;
  }

  Future<Endereco> editarEndereco({
    required String enderecoId,
    required String cep,
    required String numero,
    required String nome,
    String? complemento,
  }) async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(
      EditarEnderecoRequestDto(
        enderecoId: enderecoId,
        cep: cep,
        numero: numero,
        nome: nome,
        complemento: complemento,
      ),
    );

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.editarEnderecoOk);
    return EditarEnderecoResponseDto.fromJson(json).endereco;
  }

  Future<List<Endereco>> obterMeusEnderecos() async {
    await WsClient.instance.conectar();

    WsClient.instance.enviar(const ObterMeusEnderecosRequestDto());

    final json = await WsMessageStream.instance
        .aguardar(TipoMensagem.obterMeusEnderecosOk);
    return ObterMeusEnderecosResponseDto.fromJson(json).enderecos;
  }
}