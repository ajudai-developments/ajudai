import 'package:shared/shared.dart';
import '../../../ws/ws_client.dart';

class AuthRepository {
  final WsClient _wsClient;

  AuthRepository(this._wsClient);

  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
    String? telefone,
  }) async {
    final dto = CadastroRequestDto(
      email: email.trim(),
      senha: senha,
      nome: nome.trim(),
      cpf: CpfValidator.limpar(cpf),
      telefone: telefone != null && telefone.trim().isNotEmpty
          ? TelefoneValidator.limpar(telefone)
          : null,
    );

    final resposta = await _wsClient.enviarEAguardar(
      dto,
      tiposEsperados: {TipoMensagem.cadastroOk.valor},
    );

    return Usuario.fromJson(resposta['usuario'] as Map<String, dynamic>);
  }

  Future<Usuario> login({required String email, required String senha}) async {
    final dto = LoginRequestDto(email: email.trim(), senha: senha);

    final resposta = await _wsClient.enviarEAguardar(
      dto,
      tiposEsperados: {TipoMensagem.loginOk.valor},
    );

    return Usuario.fromJson(resposta['usuario'] as Map<String, dynamic>);
  }
}
