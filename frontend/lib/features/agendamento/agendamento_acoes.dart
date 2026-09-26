import 'package:shared/shared.dart';

import 'agendamento_repository.dart';
import 'widgets/agendamento_com_detalhes.dart';
import 'widgets/avaliacao_elegibilidade.dart';

enum AcaoAgendamento {
  cancelar,
  aceitar,
  recusar,
  iniciar,
  concluir,
  confirmarConclusao,
  avaliar,
}

typedef ExecutarAcaoAgendamento =
    Future<Agendamento> Function(
      AgendamentoComDetalhes item,
      AcaoAgendamento acao, {
      String? motivo,
    });

Future<Agendamento> executarAcaoAgendamento(
  AgendamentoRepository repositorio,
  String agendamentoId,
  AcaoAgendamento acao, {
  String? motivo,
}) {
  switch (acao) {
    case AcaoAgendamento.cancelar:
      assert(motivo != null, 'cancelar exige motivo');
      return repositorio.cancelarAgendamento(
        agendamentoId: agendamentoId,
        motivo: motivo!,
      );
    case AcaoAgendamento.aceitar:
      return repositorio.responderAgendamento(
        agendamentoId: agendamentoId,
        aceitar: true,
      );
    case AcaoAgendamento.recusar:
      return repositorio.responderAgendamento(
        agendamentoId: agendamentoId,
        aceitar: false,
      );
    case AcaoAgendamento.iniciar:
      return repositorio.iniciarAgendamento(agendamentoId);
    case AcaoAgendamento.concluir:
      return repositorio.concluirAgendamento(agendamentoId);
    case AcaoAgendamento.confirmarConclusao:
      return repositorio.confirmarConclusaoAgendamento(agendamentoId);
    case AcaoAgendamento.avaliar:
      throw UnsupportedError(
        'avaliar não é uma ação de estado — trate a navegação antes de '
        'chamar executarAcaoAgendamento.',
      );
  }
}

class AcoesAgendamento {
  final bool podeCancelar;
  final bool podeAceitar;
  final bool podeRecusar;
  final bool podeIniciar;
  final bool podeConcluir;
  final bool podeConfirmarConclusao;
  final bool podeAvaliar;
  final String? instrucao;

  const AcoesAgendamento({
    this.podeCancelar = false,
    this.podeAceitar = false,
    this.podeRecusar = false,
    this.podeIniciar = false,
    this.podeConcluir = false,
    this.podeConfirmarConclusao = false,
    this.podeAvaliar = false,
    this.instrucao,
  });

  bool get temAcaoPrincipal =>
      podeAceitar ||
      podeRecusar ||
      podeIniciar ||
      podeConcluir ||
      podeConfirmarConclusao ||
      podeAvaliar;

  static const antecedenciaIniciar = Duration(minutes: 5);

  static AcoesAgendamento calcular({
    required StatusAgendamento status,
    required DateTime horaInicio,
    required DateTime horaFim,
    required bool comoPrestador,
    bool jaAvaliado = false,
    DateTime? agora,
  }) {
    final now = agora ?? DateTime.now();

    final elegibilidade = AvaliacaoElegibilidade.calcularDe(
      status: status,
      horaInicio: horaInicio,
      jaAvaliado: jaAvaliado,
      agora: now,
    );

    if (comoPrestador) {
      // Prestador só cancela depois de ACEITAR (antes disso ele recusa);
      // depois de terminado (concluído/cancelado/contestado/recusado...)
      // não há mais o que cancelar.
      final podeCancelar =
          status == StatusAgendamento.aceito ||
          status == StatusAgendamento.emAndamento ||
          status == StatusAgendamento.aguardandoConfirmacao;

      final liberadoParaIniciar = horaInicio.subtract(antecedenciaIniciar);

      final instrucao = switch (status) {
        StatusAgendamento.pendente =>
          'Aceite ou recuse esse pedido de agendamento.',
        StatusAgendamento.aceito =>
          now.isBefore(liberadoParaIniciar)
              ? 'Você poderá iniciar o atendimento a partir de '
                    '${_hora(liberadoParaIniciar)}.'
              : 'Você já pode iniciar o atendimento.',
        StatusAgendamento.emAndamento =>
          now.isBefore(horaFim)
              ? 'Você poderá concluir o atendimento a partir de '
                    '${_hora(horaFim)}.'
              : 'O horário terminou — você já pode concluir o atendimento.',
        StatusAgendamento.aguardandoConfirmacao =>
          'Aguardando o cliente confirmar a conclusão.',
        StatusAgendamento.concluido ||
        StatusAgendamento.cancelado ||
        StatusAgendamento.contestado =>
          elegibilidade.podeAvaliar
              ? 'Que tal avaliar como foi esse atendimento?'
              : null,
        _ => null,
      };

      return AcoesAgendamento(
        podeCancelar: podeCancelar,
        podeAceitar: status == StatusAgendamento.pendente,
        podeRecusar: status == StatusAgendamento.pendente,
        podeIniciar:
            status == StatusAgendamento.aceito &&
            !now.isBefore(liberadoParaIniciar),
        podeConcluir:
            status == StatusAgendamento.emAndamento && now.isAfter(horaFim),
        podeAvaliar: elegibilidade.podeAvaliar,
        instrucao: instrucao,
      );
    }

    // Cliente pode cancelar desde que fez o pedido (pendente) até o
    // atendimento acabar — nunca depois de concluído/cancelado/
    // contestado (ou qualquer outro status "final").
    final podeCancelar =
        status == StatusAgendamento.pendente ||
        status == StatusAgendamento.aceito ||
        status == StatusAgendamento.emAndamento ||
        status == StatusAgendamento.aguardandoConfirmacao;

    final instrucao = switch (status) {
      StatusAgendamento.pendente =>
        'Aguardando o prestador aceitar seu pedido.',
      StatusAgendamento.aceito =>
        'Prestador aceitou! Aguardando o horário do atendimento.',
      StatusAgendamento.emAndamento => 'Atendimento em andamento.',
      StatusAgendamento.aguardandoConfirmacao =>
        'O prestador marcou como concluído. Confirme se está tudo certo.',
      StatusAgendamento.concluido ||
      StatusAgendamento.cancelado ||
      StatusAgendamento.contestado =>
        elegibilidade.podeAvaliar
            ? 'Que tal avaliar como foi esse atendimento?'
            : null,
      _ => null,
    };

    return AcoesAgendamento(
      podeCancelar: podeCancelar,
      podeConfirmarConclusao: status == StatusAgendamento.aguardandoConfirmacao,
      podeAvaliar: elegibilidade.podeAvaliar,
      instrucao: instrucao,
    );
  }

  static String _hora(DateTime dt) {
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }
}
