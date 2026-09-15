import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import '../servico/servico_repository.dart';
import 'prestador_repository.dart';

/// Formulário de criação de um novo serviço oferecido.
///
/// Só CRIA — não existe endpoint de editar ainda (ver
/// prestador_repository.dart), então esta tela não tem modo edição.
///
/// Fluxo: escolher categoria -> escolher tipo de serviço dentro dela
/// (isso é o `servicoId` que o backend espera) -> preencher descrição
/// e valor.
class FormServicoOferecidoScreen extends StatefulWidget {
  const FormServicoOferecidoScreen({super.key});

  @override
  State<FormServicoOferecidoScreen> createState() =>
      _FormServicoOferecidoScreenState();
}

class _FormServicoOferecidoScreenState
    extends State<FormServicoOferecidoScreen> {
  final _servicoRepository = ServicoRepository();
  final _prestadorRepository = PrestadorRepository();

  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  bool _carregandoCategorias = true;
  String? _erroCategorias;
  List<Categoria> _categorias = [];
  Categoria? _categoriaSelecionada;

  bool _carregandoServicos = false;
  String? _erroServicos;
  List<Servico> _servicos = [];
  Servico? _servicoSelecionado;

  bool _enviando = false;
  String? _erroGeral;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _carregarCategorias() async {
    setState(() {
      _carregandoCategorias = true;
      _erroCategorias = null;
    });

    try {
      final categorias = await _servicoRepository.listarCategorias();
      setState(() => _categorias = categorias);
    } on WsErroException catch (e) {
      setState(() {
        _erroCategorias = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      setState(
        () => _erroCategorias = 'Não foi possível carregar as categorias.',
      );
    } finally {
      if (mounted) setState(() => _carregandoCategorias = false);
    }
  }

  Future<void> _selecionarCategoria(Categoria? categoria) async {
    setState(() {
      _categoriaSelecionada = categoria;
      _servicoSelecionado = null;
      _servicos = [];
      _erroServicos = null;
    });

    if (categoria == null) return;

    setState(() => _carregandoServicos = true);

    try {
      final servicos = await _servicoRepository.listarServicos(
        categoriaId: categoria.id,
      );
      setState(() => _servicos = servicos);
    } on WsErroException catch (e) {
      setState(() {
        _erroServicos = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      setState(
        () => _erroServicos = 'Não foi possível carregar os tipos de serviço.',
      );
    } finally {
      if (mounted) setState(() => _carregandoServicos = false);
    }
  }

  Future<void> _salvar() async {
    final servico = _servicoSelecionado;
    final descricao = _descricaoController.text.trim();
    // Aceita vírgula ou ponto como separador decimal.
    final valorTexto = _valorController.text.trim().replaceAll(',', '.');
    final valor = double.tryParse(valorTexto);

    if (servico == null) {
      setState(() => _erroGeral = 'Selecione um tipo de serviço.');
      return;
    }
    if (descricao.isEmpty) {
      setState(() => _erroGeral = 'Descreva o serviço que você oferece.');
      return;
    }
    if (valor == null || valor < 0) {
      setState(() => _erroGeral = 'Informe um valor válido.');
      return;
    }

    setState(() {
      _enviando = true;
      _erroGeral = null;
    });

    try {
      await _prestadorRepository.criarServicoOferecido(
        servicoId: servico.id,
        descricao: descricao,
        valor: valor,
      );

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
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Novo serviço oferecido')),
      body: _carregandoCategorias
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ErrorBanner(
                      mensagem: _erroGeral ?? _erroCategorias ?? _erroServicos,
                    ),
                    Text('Categoria', style: AppTextStyles.titulo),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Categoria>(
                      initialValue: _categoriaSelecionada,
                      hint: const Text('Selecione a categoria'),
                      items: [
                        for (final categoria in _categorias)
                          DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria.nome),
                          ),
                      ],
                      onChanged: _selecionarCategoria,
                    ),
                    const SizedBox(height: 24),
                    Text('Tipo de serviço', style: AppTextStyles.titulo),
                    const SizedBox(height: 8),
                    if (_carregandoServicos)
                      const Center(child: CircularProgressIndicator())
                    else if (_categoriaSelecionada == null)
                      Text(
                        'Selecione uma categoria primeiro.',
                        style: AppTextStyles.legenda,
                      )
                    else if (_servicos.isEmpty)
                      Text(
                        'Nenhum tipo de serviço nessa categoria ainda.',
                        style: AppTextStyles.legenda,
                      )
                    else
                      DropdownButtonFormField<Servico>(
                        initialValue: _servicoSelecionado,
                        hint: const Text('Selecione o tipo de serviço'),
                        items: [
                          for (final servico in _servicos)
                            DropdownMenuItem(
                              value: servico,
                              child: Text(servico.nome),
                            ),
                        ],
                        onChanged: (servico) =>
                            setState(() => _servicoSelecionado = servico),
                      ),
                    const SizedBox(height: 24),
                    Text('Detalhes', style: AppTextStyles.titulo),
                    const SizedBox(height: 8),
                    AppTextField(
                      label: 'Descrição',
                      controller: _descricaoController,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Valor (R\$)',
                      controller: _valorController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Adicionar serviço',
                      loading: _enviando,
                      onPressed: _salvar,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
