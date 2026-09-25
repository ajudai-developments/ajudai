import 'package:ajudai/features/denuncia/widgets/seletor_prova.dart';
import 'package:flutter/material.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import 'contestacao_repository.dart';

/// Contestação de um agendamento. Recebe `agendamentoId` (String) via
/// argumento da rota — mesmo padrão de avaliar_agendamento_screen.
class ContestarAgendamentoScreen extends StatefulWidget {
  const ContestarAgendamentoScreen({super.key});

  @override
  State<ContestarAgendamentoScreen> createState() =>
      _ContestarAgendamentoScreenState();
}

class _ContestarAgendamentoScreenState
    extends State<ContestarAgendamentoScreen> {
  final _repository = ContestacaoRepository();
  final _descricaoController = TextEditingController();

  late String _agendamentoId;
  bool _argumentosCarregados = false;

  List<ItemProva> _provas = [];
  bool _enviando = false;
  String? _erro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;
    _agendamentoId = ModalRoute.of(context)!.settings.arguments as String;
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
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
      await _repository.criarContestacao(
        agendamentoId: _agendamentoId,
        descricao: descricao,
        arquivos: _provas.map((p) => p.arquivo).toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contestação enviada. Nossa equipe vai analisar.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Contestar agendamento')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBanner(mensagem: _erro),
              Text(
                'O que não saiu como combinado?',
                style: AppTextStyles.titulo,
              ),
              const SizedBox(height: 20),
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
                style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                child: _enviando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Enviar contestação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
