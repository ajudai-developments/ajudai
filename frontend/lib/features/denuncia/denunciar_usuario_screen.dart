import 'package:ajudai/features/denuncia/widgets/seletor_prova.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import 'denuncia_repository.dart';
import 'denunciar_usuario_args.dart';

/// Denúncia de um usuário. Recebe `DenunciarUsuarioArgs` (usuarioId +
/// nomeUsuario, só pra exibição) via argumento da rota.
class DenunciarUsuarioScreen extends StatefulWidget {
  const DenunciarUsuarioScreen({super.key});

  @override
  State<DenunciarUsuarioScreen> createState() => _DenunciarUsuarioScreenState();
}

class _DenunciarUsuarioScreenState extends State<DenunciarUsuarioScreen> {
  final _repository = DenunciaRepository();
  final _descricaoController = TextEditingController();

  late DenunciarUsuarioArgs _args;
  bool _argumentosCarregados = false;

  TipoDenuncia? _tipo;
  List<ItemProva> _provas = [];
  bool _enviando = false;
  String? _erro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;
    _args = ModalRoute.of(context)!.settings.arguments as DenunciarUsuarioArgs;
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_tipo == null) {
      setState(() => _erro = 'Selecione o motivo da denúncia.');
      return;
    }
    final descricao = _descricaoController.text.trim();
    if (descricao.isEmpty) {
      setState(() => _erro = 'Descreva o que aconteceu.');
      return;
    }

    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      await _repository.criarDenuncia(
        usuarioId: _args.usuarioId,
        tipoDenuncia: _tipo!,
        descricao: descricao,
        arquivos: _provas.map((p) => p.arquivo).toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Denúncia enviada. Nossa equipe vai analisar.'),
        ),
      );
      Navigator.of(context).pop();
    } on WsErroException catch (e) {
      setState(
        () => _erro = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        ),
      );
    } on WsTimeoutException {
      setState(
        () => _erro = 'Não foi possível conectar ao servidor. Tente novamente.',
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  // TipoDenuncia é do pacote shared — ajuste os rótulos reais aqui
  // quando souber os valores; por ora caio no `.name`.
  String _rotuloTipo(TipoDenuncia t) => t.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Denunciar ${_args.nomeUsuario}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBanner(mensagem: _erro),
              Text(
                'Conte pra gente o que aconteceu com ${_args.nomeUsuario}',
                style: AppTextStyles.titulo,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<TipoDenuncia>(
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final t in TipoDenuncia.values)
                    DropdownMenuItem(value: t, child: Text(_rotuloTipo(t))),
                ],
                onChanged: (v) => setState(() => _tipo = v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descricaoController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              SeletorProvas(
                valor: _provas,
                onChanged: (v) => setState(() => _provas = v),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _enviando ? null : _enviar,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  minimumSize: const Size(0, 48),
                ),
                child: _enviando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Enviar denúncia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
