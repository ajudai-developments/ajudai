enum TipoDenuncia {
  agressaoFisica('agressao_fisica'),
  agressaoVerbal('agressao_verbal'),
  agressaoSexual('agressao_sexual'),
  furto('furto'),
  ameaca('ameaca'),
  atraso('atraso'),
  ausencia('ausencia'),
  abandono('abandono'),
  naoConcluido('nao_concluido'),
  conflito('conflito'),
  outro('outro'),
  qualidadeServico('qualidade_servico'),
  comportamento('comportamento');

  final String valor;
  const TipoDenuncia(this.valor);

  static TipoDenuncia fromValor(String valor) {
    return TipoDenuncia.values.firstWhere(
      (e) => e.valor == valor,
      orElse: () =>
          throw FormatException('tipo_evento_agendamento inválido: "$valor"'),
    );
  }
}
