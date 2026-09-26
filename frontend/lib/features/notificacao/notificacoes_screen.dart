import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/async_list_view.dart';
import '../conversas/conversas_repository.dart';
import 'notificacao_repository.dart';

/// Lista as notificações do usuário, com toque pra marcar como lida
/// e navegar pra tela correspondente à categoria, e um botão no AppBar
/// pra marcar todas de uma vez.
///
/// LIMITAÇÃO: `NotificacaoDto` ainda não tem campo `lida` nem
/// `criadoEm` — então "lida"/"não lida" é um estado só LOCAL desta
/// tela (`_idsLidas`), não vem do servidor. Isso significa que, se a
/// pessoa sair da tela e voltar (ou puxar pra atualizar), tudo volta a
/// aparecer como não-lido, mesmo que já tenha marcado antes — o
/// backend registrou a leitura (persiste no banco), só não devolve
/// esse status de volta pra UI saber. Sem ordenação por data também,
/// pelo mesmo motivo.
class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  final _repository = NotificacaoRepository();
  final _conversasRepository = ConversasRepository();

  final Set<String> _idsLidas = {};
  List<NotificacaoDto> _notificacoesAtuais = [];
  bool _marcandoTodas = false;
  bool _navegando = false;

  Future<void> _marcarComoLida(NotificacaoDto notificacao) async {
    final id = notificacao.id;
    if (id == null || _idsLidas.contains(id)) return;

    // Otimista: marca localmente antes da resposta do servidor, pra
    // não deixar o toque parecendo travado. Reverte se der erro.
    setState(() => _idsLidas.add(id));

    try {
      await _repository.marcarComoLida(id);
    } catch (_) {
      if (mounted) setState(() => _idsLidas.remove(id));
    }
  }

  Future<void> _marcarTodasComoLidas() async {
    setState(() => _marcandoTodas = true);

    try {
      await _repository.marcarTodasComoLidas();
      if (mounted) {
        setState(() {
          _idsLidas.addAll(
            _notificacoesAtuais.map((n) => n.id).whereType<String>(),
          );
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível marcar todas como lidas.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _marcandoTodas = false);
    }
  }

  Future<void> _abrirNotificacao(NotificacaoDto notificacao) async {
    if (_navegando) return;
    setState(() => _navegando = true);

    try {
      await _marcarComoLida(notificacao);
      if (!mounted) return;

      final dados = notificacao.dados;

      switch (notificacao.categoria) {
        case CategoriaNotificacao.agendamento:
          final agendamentoId = dados?['agendamento_id'] as String?;
          if (agendamentoId == null) return;
          await Navigator.of(
            context,
          ).pushNamed(AppRoutes.agendamentoDetalhe, arguments: agendamentoId);
          return;

        case CategoriaNotificacao.conversa:
          final conversaId = dados?['conversa_id'] as String?;
          if (conversaId == null) return;
          try {
            final conversa = await _conversasRepository.buscarConversa(
              conversaId,
            );
            if (!mounted) return;
            await Navigator.of(
              context,
            ).pushNamed(AppRoutes.conversa, arguments: conversa);
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Não foi possível abrir a conversa.'),
                ),
              );
            }
          }
          return;

        case CategoriaNotificacao.geral:
          return;
      }
    } finally {
      if (mounted) setState(() => _navegando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          IconButton(
            tooltip: 'Marcar todas como lidas',
            icon: _marcandoTodas
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.done_all),
            onPressed: _marcandoTodas ? null : _marcarTodasComoLidas,
          ),
        ],
      ),
      body: AsyncListView<NotificacaoDto>(
        carregar: _repository.listarMinhasNotificacoes,
        mensagemVazio: 'Você não tem notificações.',
        onDadosCarregados: (notificacoes) => _notificacoesAtuais = notificacoes,
        builder: (context, notificacoes) =>
            Column(children: [for (final n in notificacoes) _buildCard(n)]),
      ),
    );
  }

  Widget _buildCard(NotificacaoDto notificacao) {
    final lida = notificacao.id != null && _idsLidas.contains(notificacao.id);
    final (icone, cor) = _iconeECor(notificacao.categoria, lida: lida);

    return Card(
      child: ListTile(
        onTap: _navegando ? null : () => _abrirNotificacao(notificacao),
        leading: Icon(icone, color: cor),
        title: Text(
          notificacao.titulo,
          style: AppTextStyles.titulo.copyWith(
            fontWeight: lida ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(notificacao.mensagem, style: AppTextStyles.corpo),
      ),
    );
  }

  (IconData, Color) _iconeECor(
    CategoriaNotificacao categoria, {
    required bool lida,
  }) {
    if (lida) {
      return (Icons.notifications_none, AppColors.textoSecundario);
    }
    return switch (categoria) {
      CategoriaNotificacao.agendamento => (
        Icons.calendar_today_rounded,
        AppColors.primary,
      ),
      CategoriaNotificacao.conversa => (
        Icons.chat_bubble_rounded,
        AppColors.primary,
      ),
      CategoriaNotificacao.geral => (Icons.notifications, AppColors.primary),
    };
  }
}
