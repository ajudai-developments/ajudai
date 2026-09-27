import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/async_list_view.dart';
import '../../core/widgets/status_chip.dart';
import 'contestacao_repository.dart';

/// Lista as contestações que o usuário logado ABRIU (não as que ele
/// recebeu de outra pessoa) — pensada pra viver dentro do Perfil.
class MinhasContestacoesScreen extends StatelessWidget {
  const MinhasContestacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Minhas contestações')),
      body: AsyncListView<ContestacaoComUrls>(
        carregar: ContestacaoRepository().listarMinhasContestacoes,
        mensagemVazio: 'Você ainda não abriu nenhuma contestação.',
        builder: (context, itens) => Column(
          children: [
            for (final item in itens) ...[
              _CartaoContestacao(item: item),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartaoContestacao extends StatelessWidget {
  final ContestacaoComUrls item;
  const _CartaoContestacao({required this.item});

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/${data.year}';

  @override
  Widget build(BuildContext context) {
    final c = item.contestacao;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Contestação sobre agendamento com ${c.contestadoNome}',
                  style: AppTextStyles.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(valor: c.status.valor),
            ],
          ),
          const SizedBox(height: 4),
          Text(_formatarData(c.criadoEm), style: AppTextStyles.legenda),
          const SizedBox(height: 10),
          Text(
            c.descricao,
            style: AppTextStyles.corpo,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (c.respostaAdmin != null) ...[
            const SizedBox(height: 12),
            _RespostaEquipe(texto: c.respostaAdmin!),
          ],
          if (item.urlsArquivos.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ContadorAnexos(quantidade: item.urlsArquivos.length),
          ],
        ],
      ),
    );
  }
}

class _RespostaEquipe extends StatelessWidget {
  final String texto;
  const _RespostaEquipe({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resposta da equipe', style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text(texto, style: AppTextStyles.corpo),
        ],
      ),
    );
  }
}

class _ContadorAnexos extends StatelessWidget {
  final int quantidade;
  const _ContadorAnexos({required this.quantidade});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.attach_file_rounded,
          size: 15,
          color: AppColors.textoSecundario,
        ),
        const SizedBox(width: 4),
        Text(
          '$quantidade anexo${quantidade == 1 ? '' : 's'}',
          style: AppTextStyles.legenda,
        ),
      ],
    );
  }
}
