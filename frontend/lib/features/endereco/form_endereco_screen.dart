import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/routes/app_routes.dart';
import 'package:ajudai/core/widgets/tela_adaptativa.dart';
import 'package:ajudai/core/ws/ws_message_stream.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/mascara_formatter.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import 'endereco_repository.dart';

/// Formulário de endereço — serve tanto para criar quanto editar.
///
/// Recebe um `Endereco?` como argumento da rota (via ModalRoute):
/// - null -> modo criação;
/// - preenchido -> modo edição, campos pré-populados.
///
/// Fluxo pensado para ser curto (estilo apps de delivery/mobilidade):
/// 1. o usuário digita o CEP (máscara 12345-678);
/// 2. ao completar os 8 dígitos, o CEP é consultado sozinho e o endereço
///    aparece num cartão de confirmação — sem botão "Verificar";
/// 3. número e complemento lado a lado;
/// 4. o nome do endereço é escolhido por atalhos (Casa / Trabalho / Outro);
/// 5. o botão de salvar fica fixo no rodapé.
///
/// Importante: nem CriarEnderecoRequestDto nem EditarEnderecoRequestDto
/// enviam logradouro/bairro/cidade/estado — só nome, cep, numero e
/// complemento. Quem resolve o resto é o backend (via CepClient). A
/// consulta aqui serve só pra CONFIRMAR pro usuário qual endereço aquele
/// CEP aponta, não pra montar o payload.
///
/// O texto do CEP fica com o traço; tudo que vai pro backend usa
/// [_cepDigitos], só com os 8 números.
class FormEnderecoScreen extends StatefulWidget {
  const FormEnderecoScreen({super.key});

  @override
  State<FormEnderecoScreen> createState() => _FormEnderecoScreenState();
}

class _FormEnderecoScreenState extends State<FormEnderecoScreen> {
  static const _atalhosNome = ['Casa', 'Trabalho', 'Outro'];

  final _enderecoRepository = EnderecoRepository();

  final _nomeController = TextEditingController();
  final _cepController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();

  Endereco? _enderecoEditando;
  bool _argumentosCarregados = false;

  bool _carregando = false;
  bool _verificandoCep = false;
  String? _erroGeral;
  String? _erroCep;

  /// Atalho de nome selecionado ('Casa', 'Trabalho' ou 'Outro').
  String _atalhoNome = 'Casa';

  // Preenchido depois de consultar o CEP (ou já vem do endereço em edição).
  // Fica nulo sempre que o texto do CEP muda, forçando nova consulta.
  ConsultarCepResponseDto? _cepVerificado;

  /// Últimos dígitos de CEP vistos pelo listener. O controller também
  /// notifica em mudança de cursor/foco (sem o texto mudar) — sem esta
  /// checagem, cada notificação apagava o CEP já confirmado.
  String _ultimoCepDigitos = '';

  /// CEP sem a máscara (só os dígitos), pra consultar e enviar ao backend.
  String get _cepDigitos => _cepController.text.replaceAll(RegExp(r'\D'), '');

  bool get _ehEdicao => _enderecoEditando != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;

    final endereco = ModalRoute.of(context)!.settings.arguments as Endereco?;
    _enderecoEditando = endereco;

    if (endereco != null) {
      _nomeController.text = endereco.nome;
      _atalhoNome = _atalhosNome.contains(endereco.nome)
          ? endereco.nome
          : 'Outro';
      // Preenchido por código: o inputFormatters não atua aqui, então
      // aplica a máscara manualmente.
      _cepController.text = MascaraFormatter.cep.formatar(endereco.cep);
      _numeroController.text = endereco.numero;
      _complementoController.text = endereco.complemento ?? '';
      _ultimoCepDigitos = _cepDigitos;
      _cepVerificado = ConsultarCepResponseDto(
        cep: endereco.cep,
        logradouro: endereco.logradouro,
        bairro: endereco.bairro,
        cidade: endereco.cidade,
        estado: endereco.estado,
      );
    } else {
      _nomeController.text = _atalhoNome;
    }

    _cepController.addListener(_aoMudarCep);
    _nomeController.addListener(() => setState(() {}));
    _numeroController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cepController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  void _aoMudarCep() {
    final digitos = _cepDigitos;
    // Ignora notificações em que os dígitos não mudaram (cursor, foco).
    if (digitos == _ultimoCepDigitos) return;
    _ultimoCepDigitos = digitos;

    setState(() {
      _cepVerificado = null;
      _erroCep = null;
      _verificandoCep = false;
    });

    // Consulta automática assim que o CEP fica completo.
    if (digitos.length == 8) _verificarCep();
  }

  void _selecionarAtalho(String atalho) {
    setState(() {
      _atalhoNome = atalho;
      _nomeController.text = atalho == 'Outro' ? '' : atalho;
    });
  }

  Future<void> _verificarCep() async {
    final consultado = _cepDigitos;

    setState(() {
      _verificandoCep = true;
      _erroCep = null;
    });

    try {
      final resultado = await _enderecoRepository.consultarCep(consultado);
      // Descarta a resposta se o usuário já mudou o CEP enquanto esperava.
      if (!mounted || consultado != _cepDigitos) return;
      setState(() => _cepVerificado = resultado);
    } on WsErroException catch (e) {
      if (!mounted || consultado != _cepDigitos) return;
      setState(() {
        _erroCep = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      if (!mounted || consultado != _cepDigitos) return;
      setState(() => _erroCep = 'Não foi possível buscar o CEP agora.');
    } catch (e) {
      // Qualquer outro erro (ex: sem conexão com o servidor) precisa
      // aparecer pro usuário, senão parece que "não acontece nada".
      debugPrint('Erro ao consultar CEP: $e');
      if (!mounted || consultado != _cepDigitos) return;
      setState(() => _erroCep = 'Não foi possível buscar o CEP agora.');
    } finally {
      if (mounted && consultado == _cepDigitos) {
        setState(() => _verificandoCep = false);
      }
    }
  }

  Future<void> _salvar() async {
    setState(() {
      _carregando = true;
      _erroGeral = null;
    });

    final complemento = _complementoController.text.trim();

    try {
      if (_ehEdicao) {
        await _enderecoRepository.editarEndereco(
          enderecoId: _enderecoEditando!.id,
          cep: _cepDigitos,
          numero: _numeroController.text,
          nome: _nomeController.text,
          complemento: complemento.isEmpty ? null : complemento,
        );
      } else {
        await _enderecoRepository.criarEndereco(
          nome: _nomeController.text,
          cep: _cepDigitos,
          numero: _numeroController.text,
          complemento: complemento.isEmpty ? null : complemento,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on WsErroException catch (e) {
      setState(() {
        _erroGeral = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      setState(() {
        _erroGeral = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } catch (e) {
      debugPrint('Erro ao salvar endereço: $e');
      setState(() {
        _erroGeral = 'Não foi possível salvar o endereço. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final podeSalvar =
        _cepVerificado != null &&
        _nomeController.text.trim().isNotEmpty &&
        _numeroController.text.trim().isNotEmpty;

    return TelaAdaptativa(
      titulo: _ehEdicao ? 'Editar endereço' : 'Novo endereço',
      rotaAtual: AppRoutes.meuPerfil, // endereço é sub-tela do perfil
      appBarMobile: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          _ehEdicao ? 'Editar endereço' : 'Novo endereço',
          style: AppTextStyles.titulo,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: ConteudoCentralizado(
          larguraMax: 560,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _ehEdicao
                      ? 'Atualize os dados do endereço'
                      : 'Onde você quer receber o serviço?',
                  style: AppTextStyles.display,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Digite o CEP e a gente encontra o resto.',
                  style: AppTextStyles.corpo,
                ),
                const SizedBox(height: 24),
                ErrorBanner(mensagem: _erroGeral),
                AppTextField(
                  label: 'CEP',
                  hint: '00000-000',
                  icone: Icons.search_rounded,
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [MascaraFormatter.cep],
                  erro: _erroCep,
                ),
                _ResultadoCep(carregando: _verificandoCep, cep: _cepVerificado),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        label: 'Número',
                        controller: _numeroController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        label: 'Complemento',
                        hint: 'Apto, bloco (opcional)',
                        controller: _complementoController,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text('Salvar como', style: AppTextStyles.titulo),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final atalho in _atalhosNome) ...[
                      _AtalhoChip(
                        label: atalho,
                        icone: _iconeAtalho(atalho),
                        selecionado: _atalhoNome == atalho,
                        onTap: () => _selecionarAtalho(atalho),
                      ),
                      if (atalho != _atalhosNome.last) const SizedBox(width: 8),
                    ],
                  ],
                ),
                if (_atalhoNome == 'Outro') ...[
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Nome do endereço',
                    hint: 'Ex: Casa da mãe, Academia',
                    controller: _nomeController,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
                const SizedBox(height: 28),
                AppButton(
                  label: _ehEdicao ? 'Salvar alterações' : 'Salvar endereço',
                  loading: _carregando,
                  onPressed: podeSalvar ? _salvar : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconeAtalho(String atalho) {
    switch (atalho) {
      case 'Casa':
        return Icons.home_rounded;
      case 'Trabalho':
        return Icons.work_rounded;
      default:
        return Icons.place_rounded;
    }
  }
}

/// Área logo abaixo do CEP: nada, "buscando..." ou o cartão com o endereço
/// encontrado.
class _ResultadoCep extends StatelessWidget {
  final bool carregando;
  final ConsultarCepResponseDto? cep;

  const _ResultadoCep({required this.carregando, required this.cep});

  @override
  Widget build(BuildContext context) {
    Widget conteudo = const SizedBox.shrink();

    if (carregando) {
      conteudo = const Padding(
        key: ValueKey('carregando'),
        padding: EdgeInsets.only(top: 12),
        child: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 10),
            Text('Buscando endereço...', style: AppTextStyles.legenda),
          ],
        ),
      );
    } else if (cep != null) {
      conteudo = Padding(
        key: const ValueKey('encontrado'),
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cep!.logradouro,
                      style: AppTextStyles.corpo.copyWith(
                        color: AppColors.textoTitulo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${cep!.bairro} • ${cep!.cidade}/${cep!.estado}',
                      style: AppTextStyles.legenda,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: conteudo,
      ),
    );
  }
}

/// Atalho de nome do endereço (Casa / Trabalho / Outro), no formato de chip.
class _AtalhoChip extends StatelessWidget {
  final String label;
  final IconData icone;
  final bool selecionado;
  final VoidCallback onTap;

  const _AtalhoChip({
    required this.label,
    required this.icone,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final corConteudo = selecionado ? AppColors.primary : AppColors.textoNormal;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selecionado ? AppColors.primary : AppColors.outline,
            width: selecionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 18, color: corConteudo),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: corConteudo,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
