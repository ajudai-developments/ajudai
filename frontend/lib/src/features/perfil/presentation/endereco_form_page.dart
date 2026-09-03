import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../../ws/ws_client.dart';
import '../state/perfil_providers.dart';

class EnderecoFormPage extends ConsumerStatefulWidget {
  final Endereco? enderecoParaEditar;

  const EnderecoFormPage({super.key, this.enderecoParaEditar});

  bool get ehEdicao => enderecoParaEditar != null;

  @override
  ConsumerState<EnderecoFormPage> createState() => _EnderecoFormPageState();
}

class _EnderecoFormPageState extends ConsumerState<EnderecoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _nomeController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();

  ConsultarCepResponseDto? _cepResolvido;
  bool _buscandoCep = false;
  bool _salvando = false;
  String? _erroCep;

  @override
  void initState() {
    super.initState();
    final endereco = widget.enderecoParaEditar;
    if (endereco != null) {
      _cepController.text = endereco.cep;
      _nomeController.text = endereco.nome;
      _numeroController.text = endereco.numero;
      _complementoController.text = endereco.complemento ?? '';
      _cepResolvido = ConsultarCepResponseDto(
        cep: endereco.cep,
        logradouro: endereco.logradouro,
        bairro: endereco.bairro,
        cidade: endereco.cidade,
        estado: endereco.estado,
      );
    }
  }

  @override
  void dispose() {
    _cepController.dispose();
    _nomeController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) {
      setState(() => _erroCep = 'CEP deve ter 8 dígitos');
      return;
    }

    setState(() {
      _buscandoCep = true;
      _erroCep = null;
      _cepResolvido = null;
    });

    try {
      final resultado = await ref
          .read(perfilRepositoryProvider)
          .consultarCep(cep);
      setState(() => _cepResolvido = resultado);
    } on WsErrorException catch (e) {
      setState(() => _erroCep = e.mensagem);
    } catch (_) {
      setState(() => _erroCep = 'Não foi possível consultar o CEP.');
    } finally {
      setState(() => _buscandoCep = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cepResolvido == null) {
      setState(() => _erroCep = 'Busque o CEP antes de salvar');
      return;
    }

    setState(() => _salvando = true);
    final repo = ref.read(perfilRepositoryProvider);
    final complemento = _complementoController.text.trim();

    try {
      if (widget.ehEdicao) {
        await repo.editarEndereco(
          enderecoId: widget.enderecoParaEditar!.id,
          nome: _nomeController.text.trim(),
          cep: _cepResolvido!.cep,
          numero: _numeroController.text.trim(),
          complemento: complemento.isEmpty ? null : complemento,
        );
      } else {
        await repo.criarEndereco(
          nome: _nomeController.text.trim(),
          cep: _cepResolvido!.cep,
          numero: _numeroController.text.trim(),
          complemento: complemento.isEmpty ? null : complemento,
        );
      }
      ref.invalidate(meusEnderecosProvider);
      if (mounted) Navigator.of(context).pop(true);
    } on WsErrorException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.mensagem)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar o endereço.')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ehEdicao ? 'Editar endereço' : 'Novo endereço'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cepController,
                    decoration: InputDecoration(
                      labelText: 'CEP',
                      errorText: _erroCep,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      if (_cepResolvido != null) {
                        setState(() => _cepResolvido = null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: FilledButton(
                    onPressed: _buscandoCep ? null : _buscarCep,
                    child: _buscandoCep
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Buscar'),
                  ),
                ),
              ],
            ),
            if (_cepResolvido != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_cepResolvido!.logradouro}\n'
                  '${_cepResolvido!.bairro} - ${_cepResolvido!.cidade}/${_cepResolvido!.estado}',
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do endereço (ex: Casa, Trabalho)',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numeroController,
              decoration: const InputDecoration(labelText: 'Número'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o número' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _complementoController,
              decoration: const InputDecoration(
                labelText: 'Complemento (opcional)',
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Salvar endereço'),
            ),
          ],
        ),
      ),
    );
  }
}
