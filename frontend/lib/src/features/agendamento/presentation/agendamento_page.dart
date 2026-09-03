// lib/src/features/agendamento/presentation/agendamento_page.dart
import 'package:ajudai/src/features/agendamento/presentation/confirmacao_pagamento_page.dart';
import 'package:ajudai/src/ws/ws_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../state/agendamento_providers.dart';
import 'widgets/endereco_selector.dart';
import 'widgets/horario_selector.dart';
import 'widgets/resumo_servico.dart';

class AgendamentoPage extends ConsumerStatefulWidget {
  final ServicoOferecidoPreview servicoOferecido;

  const AgendamentoPage({super.key, required this.servicoOferecido});

  @override
  ConsumerState<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends ConsumerState<AgendamentoPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _horaInicio;
  DateTime? _horaFim;
  Endereco? _enderecoSelecionado;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Serviço'), elevation: 0),
      body: LoadingOverlay(
        visivel: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumo do serviço
                ResumoServico(servicoOferecido: widget.servicoOferecido),
                const SizedBox(height: 24),

                // Data e hora
                HorarioSelector(
                  onHorarioSelecionado: (inicio, fim) {
                    setState(() {
                      _horaInicio = inicio;
                      _horaFim = fim;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Endereço
                EnderecoSelector(
                  onEnderecoSelecionado: (endereco) {
                    setState(() {
                      _enderecoSelecionado = endereco;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Botão confirmar
                AppButton(
                  texto: 'Confirmar Agendamento',
                  onPressed:
                      _horaInicio != null &&
                          _horaFim != null &&
                          _enderecoSelecionado != null
                      ? _confirmarAgendamento
                      : null,
                  carregando: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarAgendamento() async {
    if (_horaInicio == null ||
        _horaFim == null ||
        _enderecoSelecionado == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Criar o agendamento
      final response = await ref.read(
        criarAgendamentoProvider((
          enderecoId: _enderecoSelecionado!.id,
          horaFim: _horaFim!,
          horaInicio: _horaInicio!,
          servicoOferecidoId: widget.servicoOferecido.servicoOferecidoId,
        )).future,
      );

      if (mounted) {
        // Navegar para tela de confirmação de pagamento
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmacaoPagamentoPage(
              servicoOferecido: widget.servicoOferecido,
              endereco: _enderecoSelecionado!,
              horaInicio: _horaInicio!,
              horaFim: _horaFim!,
              agendamentoId:
                  response.servicoOferecidoId, // Ajustar conforme resposta
            ),
          ),
        );
      }
    } on WsErrorException catch (e) {
      _showError(e.mensagem);
    } catch (e) {
      _showError('Erro ao realizar agendamento. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: AppColors.erro),
    );
  }
}
