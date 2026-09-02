enum TipoConquista {
  agendamentosConcluidos,
  avaliacoesRecebidas,
  tempoDeResposta,
  tempoDeUso,
  outro;

  String get valor {
    switch (this) {
      case TipoConquista.agendamentosConcluidos:
        return 'agendamentos_concluidos';
      case TipoConquista.avaliacoesRecebidas:
        return 'avaliacoes_recebidas';
      case TipoConquista.tempoDeResposta:
        return 'tempo_de_resposta';
      case TipoConquista.tempoDeUso:
        return 'tempo_de_uso';
      case TipoConquista.outro:
        return 'outro';
    }
  }

  static TipoConquista fromValor(String valor) {
    return TipoConquista.values.firstWhere(
      (e) => e.valor == valor,
      orElse: () => throw FormatException('tipo_conquista inválido: "$valor"'),
    );
  }

  @override
  String toString() => valor;
}
