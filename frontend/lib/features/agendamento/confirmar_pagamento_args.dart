import 'package:shared/shared.dart';

/// Dados passados de `criar_agendamento_screen` pra
/// `confirmar_pagamento_screen` via argumento de rota.
///
/// Existe porque `confirmarPagamento` precisa dos MESMOS parâmetros que
/// `criarAgendamento` (servicoOferecidoId, enderecoId, horaInicio,
/// horaFim) — o preview não é suficiente sozinho pra fechar o
/// agendamento, é só o que se mostra na tela antes de confirmar.
class ConfirmarPagamentoArgs {
  final CriarAgendamentoResponseDto preview;
  final String prestadorId;
  final String enderecoId;
  final DateTime horaInicio;
  final DateTime horaFim;

  ConfirmarPagamentoArgs({
    required this.preview,
    required this.prestadorId,
    required this.enderecoId,
    required this.horaInicio,
    required this.horaFim,
  });
}