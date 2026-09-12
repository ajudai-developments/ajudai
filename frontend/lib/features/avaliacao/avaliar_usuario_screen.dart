import 'package:flutter/material.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import 'avaliacao_repository.dart';
import 'widgets/rating_input.dart';

/// Segundo e último passo do fluxo de avaliação: nota sobre a PESSOA do
/// outro lado do agendamento (o backend decide se é o prestador ou o
/// cliente, com base em quem está avaliando — não precisamos informar).
///
/// Recebe `agendamentoId` (String) via argumento da rota (a mesma
/// tela usa `pushReplacementNamed`, então este id é repassado por
/// avaliar_agendamento_screen).
///
/// Ao concluir, um único `pop()` — porque esta tela substituiu
/// avaliar_agendamento_screen na pilha, não empilhou por cima dela.
class AvaliarUsuarioScreen extends StatefulWidget {
  const AvaliarUsuarioScreen({super.key});

  @override
  State<AvaliarUsuarioScreen> createState() => _AvaliarUsuarioScreenState();
}

class _AvaliarUsuarioScreenState extends State<AvaliarUsuarioScreen> {
  final _avaliacaoRepository = AvaliacaoRepository();
  final _mensagemController = TextEditingController();

  late String _agendamentoId;
  bool _argumentosCarregados = false;

  int _nota = 0;
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
    _mensagemController.dispose();
    super.dispose();
  }

  Future<void> _finalizar() async {
    if (_nota == 0) {
      setState(() => _erro = 'Selecione uma nota antes de finalizar.');
      return;
    }

    setState(() {
      _enviando = true;
      _erro = null;
    });

    final mensagem = _mensagemController.text.trim();

    try {
      await _avaliacaoRepository.avaliarUsuario(
        agendamentoId: _agendamentoId,
        avaliacao: _nota.toDouble(),
        mensagem: mensagem.isEmpty ? null : mensagem,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avaliação enviada. Obrigado!')),
      );
      Navigator.of(context).pop();
    } on WsErroException catch (e) {
      setState(() {
        _erro = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() {
        _erro = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Avaliar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBanner(mensagem: _erro),
              Text(
                'E sobre a pessoa que atendeu esse agendamento?',
                style: AppTextStyles.titulo,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              RatingInput(valor: _nota, onChanged: (v) => setState(() => _nota = v)),
              const SizedBox(height: 24),
              TextField(
                controller: _mensagemController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Comentário (opcional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Finalizar', loading: _enviando, onPressed: _finalizar),
            ],
          ),
        ),
      ),
    );
  }
}