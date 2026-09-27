import 'package:shared/shared.dart';

/// Rótulo em português de cada [TipoDenuncia] — compartilhado entre a
/// listagem e o detalhe de denúncia.
String labelTipoDenuncia(TipoDenuncia tipo) {
  switch (tipo) {
    case TipoDenuncia.agressaoFisica:
      return 'Agressão física';
    case TipoDenuncia.agressaoVerbal:
      return 'Agressão verbal';
    case TipoDenuncia.agressaoSexual:
      return 'Agressão sexual';
    case TipoDenuncia.furto:
      return 'Furto';
    case TipoDenuncia.ameaca:
      return 'Ameaça';
    case TipoDenuncia.atraso:
      return 'Atraso';
    case TipoDenuncia.ausencia:
      return 'Ausência';
    case TipoDenuncia.abandono:
      return 'Abandono';
    case TipoDenuncia.naoConcluido:
      return 'Serviço não concluído';
    case TipoDenuncia.conflito:
      return 'Conflito';
    case TipoDenuncia.qualidadeServico:
      return 'Qualidade do serviço';
    case TipoDenuncia.comportamento:
      return 'Comportamento';
    case TipoDenuncia.outro:
      return 'Outro';
  }
}
