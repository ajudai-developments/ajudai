import 'package:flutter/material.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/ws/ws_message_stream.dart';
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
  State<ConfirmarPagamentoScreen> createState() =>
      _ConfirmarPagamentoScreenState();
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

    _args =
        ModalRoute.of(context)!.settings.arguments as ConfirmarPagamentoArgs;
  }

  String _formatarData(DateTime utc) {
    final local = utc.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return '$dia/$mes às $hora:$minuto';
  }

  String _formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }

  Future<void> _confirmar() async {
    setState(() {
      _confirmando = true;
      _erro = null;
    });

    try {
      await _agendamentoRepository.confirmarPagamento(
        prestadorId: _args.prestadorId,
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBanner(mensagem: _erro),

              // Cabeçalho: serviço + prestador
              _Card(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primarySoft,
                      child: Text(
                        _iniciais(preview.nomePrestador),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preview.nomeServico,
                            style: AppTextStyles.titulo,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'com ${preview.nomePrestador}',
                            style: AppTextStyles.corpo,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detalhes do agendamento
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _linhaInfo(
                      icone: Icons.calendar_today_outlined,
                      label: 'Data e horário',
                      valor: _formatarData(preview.horaInicio),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    _linhaInfo(
                      icone: Icons.location_on_outlined,
                      label: 'Endereço',
                      valor: preview.enderecoResumo,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Valor em destaque
              _Card(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Valor do serviço',
                        style: AppTextStyles.corpo,
                      ),
                    ),
                    Text(
                      _formatarValor(preview.valor),
                      style: AppTextStyles.titulo.copyWith(
                        fontSize: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Aviso
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.textoSecundario,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ao confirmar, o pedido de agendamento será enviado '
                        'ao prestador, que pode aceitar ou recusar.',
                        style: AppTextStyles.legenda,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Botão fixo no rodapé — mesmo padrão de FormEnderecoScreen e
      // CriarAgendamentoScreen.
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: AppButton(
              label: 'Confirmar pagamento',
              loading: _confirmando,
              onPressed: _confirmar,
            ),
          ),
        ),
      ),
    );
  }

  Widget _linhaInfo({
    required IconData icone,
    required String label,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 18, color: AppColors.textoSecundario),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.legenda),
              const SizedBox(height: 2),
              Text(
                valor,
                style: AppTextStyles.corpo.copyWith(
                  color: AppColors.textoTitulo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card branco com sombra leve, mesmo padrão visual usado em
/// AgendamentoDetalhadoScreen.
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
