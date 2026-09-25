import 'package:shared/shared.dart';

class BuscarAgendamentoDetalhadoRequestDto implements WsMessage {
  final String agendamentoId;
  const BuscarAgendamentoDetalhadoRequestDto({required this.agendamentoId});

  @override
  TipoMensagem get tipo => TipoMensagem.buscarAgendamentoDetalhado;

  factory BuscarAgendamentoDetalhadoRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return BuscarAgendamentoDetalhadoRequestDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
  };
}

class BuscarAgendamentoDetalhadoResponseDto implements WsMessage {
  final AgendamentoDetalhadoComUrls agendamento;

  BuscarAgendamentoDetalhadoResponseDto({required this.agendamento});

  @override
  TipoMensagem get tipo => TipoMensagem.buscarAgendamentoDetalhadoOk;

  factory BuscarAgendamentoDetalhadoResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return BuscarAgendamentoDetalhadoResponseDto(
      agendamento: AgendamentoDetalhadoComUrls.fromJson(
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

class AgendamentoDetalhadoComUrls {
  final AgendamentoDetalhado agendamento;
  final ContestacaoComUrls? contestacaoComUrls;

  AgendamentoDetalhadoComUrls({
    required this.agendamento,
    this.contestacaoComUrls,
  });

  factory AgendamentoDetalhadoComUrls.fromJson(Map<String, dynamic> json) {
    return AgendamentoDetalhadoComUrls(
      agendamento: AgendamentoDetalhado.fromJson(
        json['agendamento'] as Map<String, dynamic>,
      ),
      contestacaoComUrls: json['contestacao_com_urls'] == null
          ? null
          : ContestacaoComUrls.fromJson(
              json['contestacao_com_urls'] as Map<String, dynamic>,
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    'agendamento': agendamento.toJson(),
    'contestacao_com_urls': contestacaoComUrls?.toJson(),
  };
}
