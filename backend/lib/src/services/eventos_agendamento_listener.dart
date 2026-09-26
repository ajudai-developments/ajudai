import 'package:backend/src/repositories/agendamento_repository.dart';
import 'package:backend/src/services/sessao_service.dart';
import 'package:shared/shared.dart';
import 'package:supabase/supabase.dart';

class EventosAgendamentoListener {
  final SupabaseClient _client;
  final SessaoService _sessaoService;
  final AgendamentoRepository _agendamentoRepository;

  EventosAgendamentoListener({
    required this._client,
    required this._sessaoService,
    required this._agendamentoRepository,
  });

  void iniciar() {
    _client
        .channel('eventos_agendamento_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'eventos_agendamento',
          callback: (payload) async {
            final tipo = EventosAgendamentos.fromValor(
              payload.newRecord['tipo'] as String,
            );
            final agendamentoId = payload.newRecord['agendamento_id'] as String;

            final agendamento = await _agendamentoRepository.buscarPorId(
              agendamentoId,
            );
            if (agendamento == null || tipo == null) return;

            switch (tipo) {
              case EventosAgendamentos.alertaAtraso:
                _sessaoService.enviarParaUsuario(
                  agendamento.prestadorId,
                  NotificacaoDto(
                    titulo: 'Atenção: atraso no atendimento',
                    mensagem:
                        'Você está atrasado para iniciar o atendimento. Isso pode gerar penalidade caso não inicie em breve.',
                    dados: {'agendamentoId': agendamento.id},
                  ),
                );
                _sessaoService.enviarParaUsuario(
                  agendamento.usuarioId,
                  NotificacaoDto(
                    titulo: 'Atenção: atraso no atendimento',
                    mensagem:
                        'O prestador está atrasado para iniciar o atendimento.',
                    dados: {'agendamentoId': agendamento.id},
                  ),
                );
                break;

              case EventosAgendamentos.naoConcluido:
                _sessaoService.enviarParaUsuario(
                  agendamento.usuarioId,
                  NotificacaoDto(
                    titulo: 'Agendamento não concluído',
                    mensagem:
                        'O prestador não marcou a conclusão do atendimento a tempo. Você pode abrir uma reclamação se desejar. O valor de R\$${agendamento.valor} do agendamento será reembolsado.',
                    dados: {'agendamentoId': agendamento.id},
                  ),
                );
                _sessaoService.enviarParaUsuario(
                  agendamento.prestadorId,
                  NotificacaoDto(
                    titulo: 'Agendamento marcado como não concluído',
                    mensagem: 'Você não marcou a conclusão a tempo.',
                    dados: {'agendamentoId': agendamento.id},
                  ),
                );
                break;

              case EventosAgendamentos.confirmacaoAutomatica:
                _sessaoService.enviarParaUsuario(
                  agendamento.prestadorId,
                  NotificacaoDto(
                    titulo: 'Agendamento confirmado automaticamente',
                    mensagem:
                        'O sistema confirmou a conclusão automaticamente.',
                    dados: {'agendamentoId': agendamento.id},
                  ),
                );

                _sessaoService.enviarParaUsuario(
                  agendamento.usuarioId,
                  NotificacaoDto(
                    titulo: 'Avalie o serviço',
                    mensagem: 'Você tem 15 minutos para avaliar o atendimento.',
                    dados: {'agendamentoId': agendamento.id},
                  ),
                );
                _sessaoService.enviarParaUsuario(
                  agendamento.prestadorId,
                  NotificacaoDto(
                    titulo: 'Avalie o cliente',
                    mensagem: 'Você tem 15 minutos para avaliar o cliente.',
                    dados: {'agendamentoId': agendamento.id},
                  ),
                );
                break;

              case EventosAgendamentos.alertaInicio:
                _sessaoService.enviarParaUsuario(
                  agendamento.prestadorId,
                  NotificacaoDto(
                    titulo: 'Seu atendimento está próximo',
                    mensagem:
                        'Faltam poucos minutos para o início do atendimento. Você já pode iniciá-lo.',
                    dados: {'agendamentoId': agendamento.id},
                  ),
                );
                break;

              case EventosAgendamentos.alertaFinalizacao:
                _sessaoService.enviarParaUsuario(
                  agendamento.prestadorId,
                  NotificacaoDto(
                    titulo: 'Hora de finalizar o atendimento',
                    mensagem:
                        'O horário previsto para o término do atendimento chegou. Marque como concluído.',
                    dados: {'agendamentoId': agendamento.id},
                  ),
                );
                break;
            }
          },
        )
        .subscribe();
  }
}
