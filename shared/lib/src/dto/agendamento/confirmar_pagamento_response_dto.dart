import 'package:shared/shared.dart';

class ConfirmarPagamentoResponseDto implements WsMessage {
  final Agendamento agendamento;

  ConfirmarPagamentoResponseDto({required this.agendamento});

  @override
  TipoMensagem get tipo => TipoMensagem.confirmarPagamentoOk;

  factory ConfirmarPagamentoResponseDto.fromJson(Map<String, dynamic> json) {
    return ConfirmarPagamentoResponseDto(
      agendamento: Agendamento.fromJson(
        json['agendamento'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento': agendamento.toJson(),
  };
}
