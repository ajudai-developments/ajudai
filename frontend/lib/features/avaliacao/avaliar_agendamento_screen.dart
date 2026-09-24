import 'package:flutter/material.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import 'avaliacao_repository.dart';
import 'widgets/rating_input.dart';

/// Primeiro passo do fluxo de avaliação: nota sobre o SERVIÇO em si.
///
/// Recebe `agendamentoId` (String) via argumento da rota. Ao enviar com
/// sucesso, substitui a própria rota por `avaliarUsuario` (não empilha
/// por cima) — assim, quando a segunda avaliação terminar, um único
/// `pop()` volta direto pra tela de onde o fluxo começou (o detalhe do
/// agendamento), sem deixar esta tela intermediária no histórico.
///
/// Nota: o DTO também aceita um campo `descricao` além de `mensagem`,
/// mas não ficou claro qual a diferença semântica entre os dois (ambos
/// aparecem juntos no banco). Por ora só colho `mensagem` (o comentário
/// visível) e deixo `descricao` nulo — ajustar se houver um uso
/// específico pretendido pra esse campo.
class AvaliarAgendamentoScreen extends StatefulWidget {
  const AvaliarAgendamentoScreen({super.key});

  @override
  State<AvaliarAgendamentoScreen> createState() =>
      _AvaliarAgendamentoScreenState();
}

class _AvaliarAgendamentoScreenState extends State<AvaliarAgendamentoScreen> {
  final _avaliacaoRepository = AvaliacaoRepository();
  final _mensagemController = TextEditingController();

  late String _agendamentoId;
  late String _avaliadoId;
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

  Future<void> _continuar() async {
    if (_nota == 0) {
      setState(() => _erro = 'Selecione uma nota antes de continuar.');
      return;
    }

    setState(() {
      _enviando = true;
      _erro = null;
    });

    final mensagem = _mensagemController.text.trim();

    try {
      await _avaliacaoRepository.avaliarAgendamento(
        agendamentoId: _agendamentoId,
        avaliadoId: _avaliadoId,
        avaliacao: _nota.toDouble(),
        mensagem: mensagem.isEmpty ? null : mensagem,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.avaliarUsuario,
        arguments: _agendamentoId,
      );
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
      appBar: AppBar(title: const Text('Avaliar serviço')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBanner(mensagem: _erro),
              Text(
                'Como foi sua experiência com esse serviço?',
                style: AppTextStyles.titulo,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              RatingInput(
                valor: _nota,
                onChanged: (v) => setState(() => _nota = v),
              ),
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
              AppButton(
                label: 'Continuar',
                loading: _enviando,
                onPressed: _continuar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
