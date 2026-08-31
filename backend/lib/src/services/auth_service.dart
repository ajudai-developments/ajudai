import 'package:backend/src/repositories/usuario_repository.dart';
import 'package:shared/shared.dart';
import '../repositories/auth_repository.dart';
import 'sessao_service.dart';
import '../ws/ws_connection.dart';

class AuthService {
  final AuthRepository _authRepository;
  final SessaoService _sessaoService;
  final UsuarioRepository _usuarioRepositorySecret;

  AuthService(
    this._authRepository,
    this._sessaoService,
    this._usuarioRepositorySecret,
  );

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
    if (!CpfValidator.isValido(dto.cpf)) {
      throw ErroDto(
        codigo: ErroCodigo.dadosInvalidos,
        mensagem: 'CPF inválido',
      );
    }

    if (dto.telefone != null && dto.telefone!.isNotEmpty) {
      if (!TelefoneValidator.isValido(dto.telefone!)) {
        throw ErroDto(
          codigo: ErroCodigo.dadosInvalidos,
          mensagem: 'Telefone inválido',
        );
      }
    }

    final cpfLimpo = CpfValidator.limpar(dto.cpf);

    if (await _usuarioRepositorySecret.cpfJaExiste(cpfLimpo)) {
      throw ErroDto(
        codigo: ErroCodigo.cpfJaCadastrado,
        mensagem: 'CPF já cadastrado',
      );
    }

    final telefoneLimpo = dto.telefone != null && dto.telefone!.isNotEmpty
        ? TelefoneValidator.limpar(dto.telefone!)
        : null;

    final response = await _authRepository.cadastrar(
      email: dto.email,
      senha: dto.senha,
      metadata: {'nome': dto.nome, 'cpf': cpfLimpo, 'telefone': telefoneLimpo},
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
