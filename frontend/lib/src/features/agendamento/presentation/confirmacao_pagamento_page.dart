// lib/src/features/agendamento/presentation/confirmacao_pagamento_page.dart
import 'package:ajudai/src/ws/ws_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../state/agendamento_providers.dart';

class ConfirmacaoPagamentoPage extends ConsumerStatefulWidget {
  final ServicoOferecidoPreview servicoOferecido;
  final Endereco endereco;
  final DateTime horaInicio;
  final DateTime horaFim;
  final String agendamentoId;

  const ConfirmacaoPagamentoPage({
    super.key,
    required this.servicoOferecido,
    required this.endereco,
    required this.horaInicio,
    required this.horaFim,
    required this.agendamentoId,
  });

  @override
  ConsumerState<ConfirmacaoPagamentoPage> createState() =>
      _ConfirmacaoPagamentoPageState();
}

class _ConfirmacaoPagamentoPageState
    extends ConsumerState<ConfirmacaoPagamentoPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Pagamento'),
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.verde.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.verde),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Agendamento criado com sucesso!',
                        style: AppTextStyles.corpo.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.verde,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Detalhes do agendamento
              _buildDetailSection(),
              const SizedBox(height: 24),

              // Resumo do serviço
              _buildServiceSummary(),
              const SizedBox(height: 24),

              // Valores
              _buildPriceSummary(),
              const SizedBox(height: 32),

              // Botão confirmar pagamento
              AppButton(
                label: 'Confirmar Pagamento',
                onPressed: _confirmarPagamento,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Voltar para home
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Voltar para início'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoCampo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalhes do agendamento', style: AppTextStyles.label),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Data',
            value: DateFormat('dd/MM/yyyy').format(widget.horaInicio),
          ),
          _buildDetailRow(
            icon: Icons.access_time_rounded,
            label: 'Horário',
            value:
                '${DateFormat('HH:mm').format(widget.horaInicio)} - ${DateFormat('HH:mm').format(widget.horaFim)}',
          ),
          _buildDetailRow(
            icon: Icons.location_on_rounded,
            label: 'Endereço',
            value:
                '${widget.endereco.logradouro}, ${widget.endereco.numero}${widget.endereco.complemento != null ? ', ${widget.endereco.complemento}' : ''}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.cinzaEscuro, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.secundario.copyWith(fontSize: 12)),
                Text(value, style: AppTextStyles.corpo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoCampo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.vermelho.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.construction_rounded,
              color: AppColors.vermelho,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.servicoOferecido.servicoNome,
                  style: AppTextStyles.corpo.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.servicoOferecido.prestadorNome,
                  style: AppTextStyles.subtitulo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoCampo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Valor do serviço', style: AppTextStyles.corpo),
              Text(
                'R\$ ${widget.servicoOferecido.valor.toStringAsFixed(2)}',
                style: AppTextStyles.corpo.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.titulo.copyWith(fontSize: 18),
              ),
              Text(
                'R\$ ${widget.servicoOferecido.valor.toStringAsFixed(2)}',
                style: AppTextStyles.titulo.copyWith(
                  fontSize: 18,
                  color: AppColors.vermelho,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarPagamento() async {
    setState(() => _isLoading = true);

    try {
      final response = await ref.read(
        confirmarPagamentoProvider({
          servicoOferecidoId: widget.servicoOferecido.servicoOferecidoId,
          enderecoId: widget.endereco.id,
          horaInicio: widget.horaInicio,
          horaFim: widget.horaFim,
        }).future,
      );

      if (mounted) {
        // Sucesso - voltar para home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pagamento confirmado com sucesso!'),
            backgroundColor: AppColors.verde,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } on WsErrorException catch (e) {
      _showError(e.mensagem);
    } catch (e) {
      _showError('Erro ao confirmar pagamento. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: AppColors.erro,
      ),
    );
  }
}

// Provider para confirmar pagamento
final confirmarPagamentoProvider = FutureProvider.family<
  ConfirmarPagamentoResponseDto, ({
    String servicoOferecidoId,
    String enderecoId,
    DateTime horaInicio,
    DateTime horaFim,
  })
>((ref, params) async {
  final repository = ref.watch(agendamentoRepositoryProvider);
  return repository.confirmarPagamento(
    servicoOferecidoId: params.servicoOferecidoId,
    enderecoId: params.enderecoId,
    horaInicio: params.horaInicio,
    horaFim: params.horaFim,
  );
});