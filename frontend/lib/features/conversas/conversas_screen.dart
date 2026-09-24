import 'dart:async';

import 'package:ajudai/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/async_list_view.dart';
import '../../core/ws/ws_message_stream.dart';
import 'conversas_repository.dart';

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

  String _resumo(ConversaResumo conversa) {
    final texto = conversa.ultimaMensagemTexto;
    if (texto == null || texto.isEmpty) return 'Nenhuma mensagem ainda';
    return conversa.ultimaMensagemDeMim == true ? 'Você: $texto' : texto;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Conversas')),
      body: AsyncListView<ConversaResumo>(
        key: _listKey,
        carregar: _repository.listarConversas,
        mensagemVazio: 'Você ainda não iniciou nenhuma conversa.',
        builder: (context, conversas) => Column(
          children: [
            for (final conversa in conversas)
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: UserAvatar(
                    avatarUrl: conversa.outroUsuario.avatarUrl,
                    radius: 22,
                    fallbackIcon: Icons.person,
                  ),
                  title: Text(
                    conversa.outroUsuario.nome,
                    style: AppTextStyles.titulo.copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    _resumo(conversa),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _horario(conversa.ultimaMensagemEm),
                    style: AppTextStyles.legenda,
                  ),
                  onTap: () async {
                    await Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.conversa, arguments: conversa);
                    if (mounted) _listKey.currentState?.recarregar();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
