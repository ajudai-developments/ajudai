import 'package:shared/shared.dart';
import '../repositories/auth_repository.dart';
import 'sessao_service.dart';
import '../ws/ws_connection.dart';

class AuthService {
  final AuthRepository _authRepository;
  final SessaoService _sessaoService;

  AuthService(this._authRepository, this._sessaoService);

  Future<LoginResponseDto> login(
    WsConnection conexao,
    LoginRequestDto dto,
  ) async {
    final response = await _authRepository.login(
      email: dto.email,
      senha: dto.senha,
    );

    final userId = response.user?.id;
    final session = response.session;
    if (userId == null || session == null) {
      throw ErroDto(
        codigo: ErroCodigo.credenciaisInvalidas,
        mensagem: 'Login falhou',
      );
    }

    _sessaoService.criarSessao(conexao, userId, session);
    return LoginResponseDto(userId: userId);
  }

  Future<CadastroResponseDto> cadastrar(
    WsConnection conexao,
    CadastroRequestDto dto,
  ) async {
    final response = await _authRepository.cadastrar(
      email: dto.email,
      senha: dto.senha,
      metadata: dto.toSupabaseMetadata(),
    );

    final userId = response.user?.id;
    final session = response.session;
    if (userId == null || session == null) {
      throw ErroDto(
        codigo: ErroCodigo.erroInterno,
        mensagem: 'Cadastro falhou',
      );
    }

    _sessaoService.criarSessao(conexao, userId, session);
    return CadastroResponseDto(userId: userId);
  }
}
