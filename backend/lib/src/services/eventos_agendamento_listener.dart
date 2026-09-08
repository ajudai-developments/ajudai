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
            final tipo = payload.newRecord['tipo'] as String;
            final agendamentoId = payload.newRecord['agendamento_id'] as String;

            final agendamento = await _agendamentoRepository.buscarPorId(
              agendamentoId,
            );
            if (agendamento == null) return;

            switch (tipo) {
              case 'alerta_atraso':
                _sessaoService.enviarParaUsuario(
                  agendamento.prestadorId,
                  NotificacaoDto(
                    titulo: 'Atenção: atraso no atendimento',
                    mensagem:
                        'Você está atrasado para iniciar o atendimento. Isso pode gerar penalidade caso não inicie em breve.',
                    dados: {'agendamentoId': agendamento.id},
                  ),
                );
                break;

              case 'denuncia_atraso':
                _sessaoService.enviarParaUsuario(
                  agendamento.prestadorId,
                  NotificacaoDto(
                    titulo: 'Denúncia registrada',
                    mensagem:
                        'Uma denúncia automática foi registrada por atraso no início do atendimento.',
                    dados: {'agendamentoId': agendamento.id},
                  ),
                );
                break;

              case 'nao_concluido':
                _sessaoService.enviarParaUsuario(
                  agendamento.usuarioId,
                  NotificacaoDto(
                    titulo: 'Agendamento não concluído',
                    mensagem:
                        'O sistema não recebeu confirmação de conclusão a tempo.',
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

              case 'confirmacao_automatica':
                _sessaoService.enviarParaUsuario(
                  agendamento.prestadorId,
                  NotificacaoDto(
                    titulo: 'Agendamento confirmado automaticamente',
                    mensagem:
                        'O sistema confirmou a conclusão automaticamente.',
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
