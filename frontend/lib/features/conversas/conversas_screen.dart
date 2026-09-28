import 'dart:async';

import 'package:ajudai/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/async_list_view.dart';
import '../../core/widgets/cabecalho_simples.dart';
import '../../core/ws/ws_message_stream.dart';
import 'conversas_repository.dart';

/// Lista de conversas do usuário.
///
/// Cabeçalho vermelho da marca + cada conversa como uma linha (avatar,
/// nome, última mensagem e horário) separada por um divisor fino —
/// formato de app de mensagens, porque a lista pode ser longa.
class ConversasScreen extends StatefulWidget {
  const ConversasScreen({super.key});

  @override
  State<ConversasScreen> createState() => _ConversasScreenState();
}

class _ConversasScreenState extends State<ConversasScreen> {
  final _repository = ConversasRepository();
  final _listKey = GlobalKey<AsyncListViewState<ConversaResumo>>();
  StreamSubscription<Map<String, dynamic>>? _mensagensSubscription;

  @override
  void initState() {
    super.initState();
    _mensagensSubscription = WsMessageStream.instance.stream
        .where(
          (json) =>
              TipoMensagem.fromValor(json['tipo'] as String?) ==
              TipoMensagem.novaMensagem,
        )
        .listen((_) => _listKey.currentState?.recarregar());
  }

  @override
  void dispose() {
    _mensagensSubscription?.cancel();
    super.dispose();
  }

  /// Texto da última mensagem + se ela é um anexo.
  ///
  /// O model só traz o TEXTO da última mensagem. Quando é só um anexo
  /// (foto, vídeo ou áudio, sem legenda) o texto vem vazio, mas
  /// `ultimaMensagemEm` existe — então há mensagem, só não há texto.
  /// Nesse caso mostra "Arquivo anexado" em vez de "Nenhuma mensagem".
  ({String texto, bool anexo}) _resumo(ConversaResumo conversa) {
    final texto = conversa.ultimaMensagemTexto;
    final deMim = conversa.ultimaMensagemDeMim == true;

    if (texto == null || texto.isEmpty) {
      if (conversa.ultimaMensagemEm == null) {
        return (texto: 'Nenhuma mensagem ainda', anexo: false);
      }
      return (
        texto: deMim ? 'Você: Arquivo anexado' : 'Arquivo anexado',
        anexo: true,
      );
    }

    return (texto: deMim ? 'Você: $texto' : texto, anexo: false);
  }

  String _horario(DateTime? data) {
    if (data == null) return '';
    final local = data.toLocal();
    final agora = DateTime.now();
    if (local.year == agora.year &&
        local.month == agora.month &&
        local.day == agora.day) {
      return DateFormat('HH:mm').format(local);
    }
    return DateFormat('dd/MM').format(local);
  }

  Future<void> _abrirConversa(ConversaResumo conversa) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.conversa, arguments: conversa);
    if (mounted) _listKey.currentState?.recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CabecalhoSimples(
            titulo: 'Conversas',
            subtitulo: 'Suas mensagens com clientes e prestadores',
          ),
          Expanded(
            child: AsyncListView<ConversaResumo>(
              key: _listKey,
              carregar: _repository.listarConversas,
              mensagemVazio:
                  'Você ainda não tem conversas.\nInicie uma pelo perfil de um prestador.',
              builder: (context, conversas) => Column(
                children: [
                  for (var i = 0; i < conversas.length; i++)
                    _ConversaItem(
                      conversa: conversas[i],
                      resumo: _resumo(conversas[i]).texto,
                      ehAnexo: _resumo(conversas[i]).anexo,
                      horario: _horario(conversas[i].ultimaMensagemEm),
                      mostrarDivisor: i < conversas.length - 1,
                      onTap: () => _abrirConversa(conversas[i]),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversaItem extends StatelessWidget {
  final ConversaResumo conversa;
  final String resumo;
  final bool ehAnexo;
  final String horario;
  final bool mostrarDivisor;
  final VoidCallback onTap;

  const _ConversaItem({
    required this.conversa,
    required this.resumo,
    required this.ehAnexo,
    required this.horario,
    required this.mostrarDivisor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                UserAvatar(
                  avatarUrl: conversa.outroUsuario.avatarUrl,
                  radius: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversa.outroUsuario.nome,
                              style: AppTextStyles.titulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(horario, style: AppTextStyles.legenda),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (ehAnexo) ...[
                            const Icon(
                              Icons.attach_file_rounded,
                              size: 15,
                              color: AppColors.textoSecundario,
                            ),
                            const SizedBox(width: 2),
                          ],
                          Expanded(
                            child: Text(
                              resumo,
                              style: AppTextStyles.corpo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (mostrarDivisor)
          const Divider(height: 1, indent: 66, color: AppColors.outline),
      ],
    );
  }
}
