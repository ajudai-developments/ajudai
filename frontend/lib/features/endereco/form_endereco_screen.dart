import 'package:ajudai/core/ws/ws_message_stream.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
/// Importante: nem CriarEnderecoRequestDto nem EditarEnderecoRequestDto
/// enviam logradouro/bairro/cidade/estado — só nome, cep, numero e
/// complemento. Quem resolve o resto do endereço a partir do CEP é o
/// backend (via CepClient). Por isso, a "verificação de CEP" aqui serve
/// só pra CONFIRMAR pro usuário pra qual endereço aquele CEP aponta antes
/// de enviar, não pra montar o payload.
class FormEnderecoScreen extends StatefulWidget {
  const FormEnderecoScreen({super.key});

  @override
  State<FormEnderecoScreen> createState() => _FormEnderecoScreenState();
}

class _FormEnderecoScreenState extends State<FormEnderecoScreen> {
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

  // Preenchido depois de verificar o CEP (ou já vem do endereço em edição).
  // Fica nulo sempre que o texto do CEP muda, forçando nova verificação.
  ConsultarCepResponseDto? _cepVerificado;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;

    final endereco = ModalRoute.of(context)!.settings.arguments as Endereco?;
    _enderecoEditando = endereco;

    if (endereco != null) {
      _nomeController.text = endereco.nome;
      _cepController.text = endereco.cep;
      _numeroController.text = endereco.numero;
      _complementoController.text = endereco.complemento ?? '';
      _cepVerificado = ConsultarCepResponseDto(
        cep: endereco.cep,
        logradouro: endereco.logradouro,
        bairro: endereco.bairro,
        cidade: endereco.cidade,
        estado: endereco.estado,
      );
    }

    _cepController.addListener(() {
      if (_cepVerificado != null) setState(() => _cepVerificado = null);
    });
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

  bool get _ehEdicao => _enderecoEditando != null;

  Future<void> _verificarCep() async {
    setState(() {
      _verificandoCep = true;
      _erroCep = null;
    });

    try {
      final resultado = await _enderecoRepository.consultarCep(_cepController.text);
      setState(() => _cepVerificado = resultado);
    } on WsErroException catch (e) {
      setState(() {
        _erroCep = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() => _erroCep = 'Não foi possível verificar o CEP agora.');
    } finally {
      if (mounted) setState(() => _verificandoCep = false);
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
          cep: _cepController.text,
          numero: _numeroController.text,
          nome: _nomeController.text,
          complemento: complemento.isEmpty ? null : complemento,
        );
      } else {
        await _enderecoRepository.criarEndereco(
          nome: _nomeController.text,
          cep: _cepController.text,
          numero: _numeroController.text,
          complemento: complemento.isEmpty ? null : complemento,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on WsErroException catch (e) {
      setState(() {
        _erroGeral = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() {
        _erroGeral = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Só deixa salvar depois que o CEP atual foi confirmado — evita
    // enviar um endereço pra um CEP que nunca foi validado nesta sessão
    // de edição do formulário.
    final podeSalvar = _cepVerificado != null &&
        _nomeController.text.trim().isNotEmpty &&
        _numeroController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_ehEdicao ? 'Editar endereço' : 'Novo endereço')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBanner(mensagem: _erroGeral),
              AppTextField(
                label: 'Nome do endereço (ex: Casa, Trabalho)',
                controller: _nomeController,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'CEP',
                      controller: _cepController,
                      keyboardType: TextInputType.number,
                      erro: _erroCep,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AppButton(
                      label: 'Verificar',
                      loading: _verificandoCep,
                      onPressed: _cepController.text.trim().isEmpty ? null : _verificarCep,
                    ),
                  ),
                ],
              ),
              if (_cepVerificado != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${_cepVerificado!.logradouro}, '
                  '${_cepVerificado!.bairro} - '
                  '${_cepVerificado!.cidade}/${_cepVerificado!.estado}',
                  style: AppTextStyles.legenda,
                ),
              ],
              const SizedBox(height: 16),
              AppTextField(
                label: 'Número',
                controller: _numeroController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Complemento (opcional)',
                controller: _complementoController,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: _ehEdicao ? 'Salvar alterações' : 'Adicionar endereço',
                loading: _carregando,
                onPressed: podeSalvar ? _salvar : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}