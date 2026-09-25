import 'package:shared/shared.dart';

import 'agendamento_repository.dart';
import 'widgets/agendamento_com_detalhes.dart';

/// Ações de ciclo de vida que um usuário pode disparar sobre um
/// agendamento. `avaliar` não muda estado nenhum no backend — é só
/// navegação pra tela de avaliação — mas entra aqui pra ficar junto
/// das outras ações na hora de decidir o que mostrar na tela.
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

/// Chama o método certo do repositório pra cada ação de estado. Não
/// trata `AcaoAgendamento.avaliar` — essa é só navegação, quem chama
/// deve tratar antes de chegar aqui.
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

/// Quais ações fazem sentido mostrar agora, dado o status, o horário
/// marcado e o papel de quem está olhando.
///
/// A validação de verdade é sempre feita pelo backend — isso aqui só
/// decide o que HABILITAR na tela, pra não deixar a pessoa nem tentar
/// uma ação fora de hora.
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

  /// Antecedência mínima pro prestador poder iniciar o atendimento,
  /// contada a partir do horário de INÍCIO marcado (ver observação no
  /// topo da resposta sobre essa regra).
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

    // Cancelamento só faz sentido depois que foi aceito — se ainda tá
    // pendente, não tem nada "marcado" pra cancelar (o prestador recusa,
    // e o cliente simplesmente aguarda ou o pedido expira).
    final podeCancelar =
        status == StatusAgendamento.aceito ||
        status == StatusAgendamento.emAndamento ||
        status == StatusAgendamento.aguardandoConfirmacao;

    if (comoPrestador) {
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
        StatusAgendamento.concluido =>
          jaAvaliado ? null : 'Que tal avaliar como foi esse atendimento?',
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
        podeAvaliar: status == StatusAgendamento.concluido && !jaAvaliado,
        instrucao: instrucao,
      );
    }

    final instrucao = switch (status) {
      StatusAgendamento.pendente =>
        'Aguardando o prestador aceitar seu pedido.',
      StatusAgendamento.aceito =>
        'Prestador aceitou! Aguardando o horário do atendimento.',
      StatusAgendamento.emAndamento => 'Atendimento em andamento.',
      StatusAgendamento.aguardandoConfirmacao =>
        'O prestador marcou como concluído. Confirme se está tudo certo.',
      StatusAgendamento.concluido =>
        jaAvaliado ? null : 'Que tal avaliar como foi esse atendimento?',
      _ => null,
    };

    return AcoesAgendamento(
      podeCancelar: true,
      podeConfirmarConclusao: status == StatusAgendamento.aguardandoConfirmacao,
      podeAvaliar: status == StatusAgendamento.concluido && !jaAvaliado,
      instrucao: instrucao,
    );
  }

  static String _hora(DateTime dt) {
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }
}
