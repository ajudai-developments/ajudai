import 'package:shared/shared.dart';

/// Traduz ErroCodigo (vindo do ErroDto do backend) em mensagem amigável
/// para exibir em ErrorBanner / SnackBar.
class ErroMapper {
  ErroMapper._();

  static String paraMensagem(ErroCodigo codigo, {String? mensagemServidor}) {
    switch (codigo) {
      case ErroCodigo.naoAutenticado:
        return 'Você precisa entrar na sua conta para continuar.';
      case ErroCodigo.credenciaisInvalidas:
        return 'E-mail ou senha inválidos.';
      case ErroCodigo.sessaoExpirada:
        return 'Sua sessão expirou. Entre novamente.';
      case ErroCodigo.dadosInvalidos:
        return mensagemServidor ?? 'Dados inválidos.';
      case ErroCodigo.emailJaCadastrado:
        return 'Este e-mail já está cadastrado.';
      case ErroCodigo.cpfJaCadastrado:
        return 'Este CPF já está cadastrado.';
      case ErroCodigo.senhaFraca:
        return 'A senha é muito fraca.';
      case ErroCodigo.limiteEnderecosExcedido:
        return 'Você atingiu o limite de endereços cadastrados.';
      case ErroCodigo.enderecoNaoEncontrado:
        return 'Endereço não encontrado.';
      case ErroCodigo.jaEUmPrestador:
        return 'Você já é um prestador.';
      case ErroCodigo.solicitacaoEmAndamento:
        return 'Já existe uma solicitação em andamento.';
      case ErroCodigo.suspensoComoPrestador:
        return 'Sua conta de prestador está suspensa.';
      case ErroCodigo.naoPermitido:
        return 'Você não tem permissão para fazer isso.';
      case ErroCodigo.pagamentoRecusado:
        return 'Pagamento recusado. Tente novamente.';
      case ErroCodigo.conflitoHorario:
        return 'Esse horário já está ocupado.';
      case ErroCodigo.erroInterno:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}