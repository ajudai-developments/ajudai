import 'package:ajudai/core/ws/ws_message_stream.dart';
import 'package:flutter/material.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_banner.dart';
import 'agendamento_repository.dart';
import 'confirmar_pagamento_args.dart';

/// Tela de confirmação de pagamento — último passo do fluxo de
/// agendamento. Mostra o preview gerado por `criarAgendamento` e, ao
/// confirmar, chama `confirmarPagamento` (que é quem de fato cria o
/// agendamento no backend).
///
/// Recebe um `ConfirmarPagamentoArgs` via argumento da rota.
class ConfirmarPagamentoScreen extends StatefulWidget {
  const ConfirmarPagamentoScreen({super.key});

  @override
  State<ConfirmarPagamentoScreen> createState() => _ConfirmarPagamentoScreenState();
}

class _ConfirmarPagamentoScreenState extends State<ConfirmarPagamentoScreen> {
  final _agendamentoRepository = AgendamentoRepository();

  late ConfirmarPagamentoArgs _args;
  bool _argumentosCarregados = false;

  bool _confirmando = false;
  String? _erro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;

    _args = ModalRoute.of(context)!.settings.arguments as ConfirmarPagamentoArgs;
  }

  String _formatarData(DateTime utc) {
    final local = utc.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return '$dia/$mes às $hora:$minuto';
  }

  Future<void> _confirmar() async {
    setState(() {
      _confirmando = true;
      _erro = null;
    });

    try {
      await _agendamentoRepository.confirmarPagamento(
        servicoOferecidoId: _args.preview.servicoOferecidoId,
        enderecoId: _args.enderecoId,
        horaInicio: _args.horaInicio,
        horaFim: _args.horaFim,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento realizado com sucesso!')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.meusAgendamentos,
        ModalRoute.withName(AppRoutes.home),
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
      if (mounted) setState(() => _confirmando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _args.preview;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Confirmar agendamento')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBanner(mensagem: _erro),
              Text(preview.nomeServico, style: AppTextStyles.titulo),
              const SizedBox(height: 4),
              Text('com ${preview.nomePrestador}', style: AppTextStyles.corpo),
              const SizedBox(height: 16),
              _linha('Data e horário', _formatarData(preview.horaInicio)),
              _linha('Endereço', preview.enderecoResumo),
              _linha('Valor', 'R\$ ${preview.valor.toStringAsFixed(2)}'),
              const SizedBox(height: 24),
              Text(
                'Ao confirmar, o pedido de agendamento será enviado ao '
                'prestador, que pode aceitar ou recusar.',
                style: AppTextStyles.legenda,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Confirmar pagamento',
                loading: _confirmando,
                onPressed: _confirmar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linha(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: AppTextStyles.legenda)),
          Expanded(child: Text(valor, style: AppTextStyles.corpo)),
        ],
      ),
    );
  }
}